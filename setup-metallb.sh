#!/usr/bin/env bash

CLUSTER_NAME=$1
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/namespace.yaml --context=kind-$CLUSTER_NAME
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" --context=kind-$CLUSTER_NAME
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/metallb.yaml --context=kind-$CLUSTER_NAME
kubectl apply -f ./$CLUSTER_NAME/metallb-config-map.yaml --context=kind-$CLUSTER_NAME