#!/usr/bin/env bash

# generate ca
cfssl gencert -initca ./certs/ca/ca-csr.json | cfssljson -bare ./certs/ca/ca

# generate clustermesh cert
cfssl gencert -ca ./certs/ca/ca.pem \
              -ca-key ./certs/ca/ca-key.pem \
              -config ./certs/cfssl.json \
              -profile=clustermesh-apiserver-server-cert \
              ./certs/server/csr.json | cfssljson -bare ./certs/server/cert

# generate clustermesh admin cert
cfssl gencert -ca ./certs/ca/ca.pem \
              -ca-key ./certs/ca/ca-key.pem \
              -config ./certs/cfssl.json \
              -profile=clustermesh-apiserver-admin-cert \
              ./certs/admin/csr.json | cfssljson -bare ./certs/admin/cert

# generate clustermesh client cert
cfssl gencert -ca ./certs/ca/ca.pem \
              -ca-key ./certs/ca/ca-key.pem \
              -config ./certs/cfssl.json \
              -profile=clustermesh-apiserver-client-cert \
              ./certs/client/csr.json | cfssljson -bare ./certs/client/cert

CA=$(base64 -w 0 ./certs/ca/ca.pem)
CA_KEY=$(base64 -w 0 ./certs/ca/ca-key.pem)
SERVER_CERT=$(base64 -w 0 ./certs/server/cert.pem)
SERVER_KEY=$(base64 -w 0 ./certs/server/cert-key.pem)
ADMIN_CERT=$(base64 -w 0 ./certs/admin/cert.pem)
ADMIN_KEY=$(base64 -w 0 ./certs/admin/cert-key.pem)
CLIENT_CERT=$(base64 -w 0 ./certs/client/cert.pem)
CLIENT_KEY=$(base64 -w 0 ./certs/client/cert-key.pem)
ETCD_CFG_KIND1=$(base64 -w 0 ./kind-1/etcd-cfg.yaml)
ETCD_CFG_KIND2=$(base64 -w 0 ./kind-2/etcd-cfg.yaml)

# rm ./manifests/cilium-ca-secret.yaml
cat <<EOT > ./manifests/cilium-ca-secret.yaml
apiVersion: v1
data:
  ca.crt: $CA
  ca.key: $CA_KEY
kind: Secret
metadata:
  namespace: kube-system
  name: cilium-ca
EOT

# rm ./manifests/cilium-clustermesh-secret.yaml
cat <<EOT > ./manifests/cilium-clustermesh-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  namespace: kube-system
  name: cilium-clustermesh
data:
  kind-1: $ETCD_CFG_KIND1
  kind-1.etcd-client-ca.crt: $CA
  kind-1.etcd-client.crt: $CLIENT_CERT
  kind-1.etcd-client.key: $CLIENT_KEY
  kind-2: $ETCD_CFG_KIND2
  kind-2.etcd-client-ca.crt: $CA
  kind-2.etcd-client.crt: $CLIENT_CERT
  kind-2.etcd-client.key: $CLIENT_KEY
EOT

echo "Helm Config - Replace it into the values.yaml in each cluster Cilium Helm Chart Values"
echo "
clustermesh:
  useAPIServer: true
  apiserver:
    tls:
      auto:
        enabled: false   
      ca:
        cert: $CA
        key: $CA_KEY
      server:
        cert: $SERVER_CERT
        key: $SERVER_KEY
      admin:
        cert: $ADMIN_CERT
        key: $ADMIN_KEY
      client:
        cert: $CLIENT_CERT      
        key: $CLIENT_KEY
"