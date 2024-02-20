#!/bin/bash

az aks install-cli

az aks install-cli --client-version 

az login --use-device-code
az aks get-credentials --resource-group aks-solution --name rkaksdev 

https://github.com/Azure-Samples/aks-store-demo?tab=readme-ov-file#run-on-any-kubernetes

kubectl create ns pets
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/aks-store-all-in-one.yaml -n pets


kubectl get get deployment

kubectl get get service

kubectl get get pod

kubectl apply -n pets -f aks-openai-aiservice.yaml


kubectl delete -n pets -f aks-openai-aiservice.yaml