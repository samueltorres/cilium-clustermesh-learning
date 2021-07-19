#!/usr/bin/env bash

CLUSTER_NAME=$1

helm upgrade -i cilium cilium/cilium --version 1.10.2 \
   --namespace kube-system \
   --kube-context kind-$CLUSTER_NAME \
   -f ./$CLUSTER_NAME/values.yaml

kubectl apply -f ./manifests/cilium-ca-secret.yaml \
   --namespace kube-system \
   --context kind-$CLUSTER_NAME

kubectl apply -f ./manifests/cilium-clustermesh-secret.yaml \
   --namespace kube-system \
   --context kind-$CLUSTER_NAME

kubectl patch ds cilium --patch-file=./manifests/cilium-ds-patch.yaml \
   --namespace kube-system \
   --context kind-$CLUSTER_NAME