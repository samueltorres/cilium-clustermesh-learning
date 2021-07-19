#!/usr/bin/env bash

CILIUM_NAMESPACE="kube-system"
CILIUM_VERSION="v1.10.2"
CLUSTER_NAME_PREFIX="kind-"
CLUSTER_1_NAME="${CLUSTER_NAME_PREFIX}1"
CLUSTER_1_CONTEXT="kind-${CLUSTER_1_NAME}"
CLUSTER_2_NAME="${CLUSTER_NAME_PREFIX}2"
CLUSTER_2_CONTEXT="kind-${CLUSTER_2_NAME}"


kubectl config use "${CLUSTER_1_CONTEXT}"
cilium install --cluster-name "${CLUSTER_1_NAME}" --cluster-id "${CLUSTER_1_NAME/${CLUSTER_NAME_PREFIX}/}" --ipam kubernetes --version "${CILIUM_VERSION}"
kubectl config use "${CLUSTER_2_CONTEXT}"
cilium install --cluster-name "${CLUSTER_2_NAME}" --cluster-id "${CLUSTER_2_NAME/${CLUSTER_NAME_PREFIX}/}" --ipam kubernetes --version "${CILIUM_VERSION}"

cilium clustermesh enable --context "${CLUSTER_1_CONTEXT}" --service-type LoadBalancer
cilium clustermesh enable --context "${CLUSTER_2_CONTEXT}" --service-type LoadBalancer
cilium clustermesh status --context "${CLUSTER_1_CONTEXT}" --wait
cilium clustermesh status --context "${CLUSTER_2_CONTEXT}" --wait
cilium clustermesh connect --context "${CLUSTER_1_CONTEXT}" --destination-context "${CLUSTER_2_CONTEXT}"
cilium clustermesh status --context "${CLUSTER_1_CONTEXT}" --wait
cilium clustermesh status --context "${CLUSTER_2_CONTEXT}" --wait