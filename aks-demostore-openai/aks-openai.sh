#!/bin/bash

# This code is used to demonstrate the experience in my blog posts 
# 0.https://roykim.ca/2024/02/19/deploying-azure-kubernetes-service-demo-store-app-with-azure-open-ai-part-1/

# login into azure and aks cluster
az aks install-cli --client-version 

az login --use-device-code
az aks get-credentials --resource-group aks-solution --name rkaksdev 

# AKS Demo Store App with OpenAI
https://github.com/Azure-Samples/aks-store-demo?tab=readme-ov-file#run-on-any-kubernetes

# Create Kubernetes Namespace to deploy the application
kubectl create ns pets
kubectl config set-context --current --namespace=pets

# Deploy the application (this does not include the AI service)
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/aks-store-all-in-one.yaml -n pets

kubectl get deployments
kubectl get services
kubectl get pods

# Deploy the AI service
kubectl apply -n pets -f aks-openai-aiservice.yaml


# cleanup
kubectl delete -n pets -f aks-openai-aiservice.yaml
kubectl delete ns pets
