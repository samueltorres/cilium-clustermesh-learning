#!/bin/bash
CLUSTER_NAME=$1
kind create cluster --config=./$CLUSTER_NAME/cluster.yaml --name=$CLUSTER_NAME