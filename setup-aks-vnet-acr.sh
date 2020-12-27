#!/bin/bash
# manage-kubernetes.sh

az account show -o table
az account list -o table
az account set -s 'Visual Studio Enterprise'
az subscription -n 'Visual Studio Enterprise'

# AKS
rgName='linux-demos' #'aks-solution'
aksName='rkaks-vsent'
location='canadacentral'

# create AKS cluster
####################
az group create -l $location -n $rgName #--subscription $appSubId

# Azure Container Registry
# set this to the name of your Azure Container Registry.  It must be globally unique
acrName=rkimacrVSEnt #name is global
# Note: acr in enterprise rg in Enterprise subscription
az acr create --name $acrName --resource-group $rgName -l $location --sku Basic
acrResourceId=$(az acr show --name $acrName --resource-group $rgName --query "id" --output tsv)
az acr update -n $acrName --admin-enabled true
acr_userName=$(az acr credential show -n $acrName --query="username" -o tsv)
acr_pwd=$(az acr credential show -n $acrName --query="passwords[0].value" -o tsv)
echo $acr_userName $acr_pwd

# create vnet and subnet
az network vnet create -g $rgName -n aksVnet  -l $location --address-prefix 10.1.0.0/24 \
    --subnet-name akssubnet --subnet-prefix 10.1.0.0/25 
subnetId=$(az network vnet subnet show --resource-group $rgName --vnet-name aksVnet --name akssubnet --query id -o tsv)
echo $subnetId

# existing subnets
az network vnet subnet list --resource-group $rgName --vnet-name aksVnet -o tsv
subnetId=$(az network vnet subnet show --resource-group $rgName --vnet-name aksVnet --name akssubnet --query id -o tsv)
# VM SKUS 
az vm list-skus --location $location -o table
# versions
az aks get-versions --location $location --output table

az aks create --resource-group $rgName --name $aksName \
    --kubernetes-version 1.19.1 \
    --location $location \
    --node-vm-size Standard_D2_v3 \
    --vm-set-type VirtualMachineScaleSets \
    --node-osdisk-size 30 \
    --node-count 1 --max-pods 30 \
    --network-plugin azure \
    --vnet-subnet-id $subnetId \
    --load-balancer-sku Basic \
    --generate-ssh-keys \
    --enable-cluster-autoscaler --min-count 1 --max-count 5 \
    --enable-aad \
    --enable-managed-identity \
    --attach-acr $acrResourceId
    #--enable-addons monitoring --workspace-resource-id $logWorkspaceResourceId 

# Side Notes
# Standard_D2_v3 2vCpu 8GB Ram, not premium storage
# Networking config options: --service-cidr 10.2.0.0/24 --dns-service-ip 10.2.0.10 --docker-bridge-address 172.17.0.1/16 \
 

az aks get-credentials -n $aksName -g $rgName

az aks show  -n $aksName -g $rgName

# Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

kubectl delete clusterrolebinding kubernetes-dashboard 
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard --insecure-skip-tls-verify 
kubectl create clusterrolebinding serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin --group=system:serviceaccounts

kubectl get secrets -n kube-system | grep dashboard-token 
kubectl get secrets -n kube-system -o json
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
echo $TOKEN # | xclip --selection clipboard -o
curl http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/login

kubectl get pods -n kubernetes-dashboard -o jsonpath | grep kubernetes-dashboard.*
kubectl port-forward $(kubectl get pods -n kubernetes-dashboard -o name | grep kubernetes) 8443:8443

# Create a namespace for your ingress resources
kubectl create namespace ingress-basic

# Add the official stable repo
helm repo update
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Use Helm to deploy an NGINX ingress controller
helm install nginx stable/nginx-ingress \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

kubectl get service -l app=nginx-ingress --namespace ingress-basic
kubectl get service nginx-nginx-ingress-controller --namespace ingress-basic

# Public IP address of your ingress controller
# Look up in resource group in Azure Portal
publicIP='<PUBLIC IP>'

## Add an A record to your DNS zone ##

# Set A record to GoDaddy DNS 
# OR
# Name to associate with public IP address
DNSNAME="demo-aks-ingress"
# Get the resource-id of the public ip
PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)
# Update public ip address with DNS name
az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME
# Display the FQDN
az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv

## Install cert-manager

# Install the CustomResourceDefinition resources separately
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml

# Label the ingress-basic namespace to disable resource validation
kubectl label namespace ingress-basic cert-manager.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install \
  cert-manager \
  --namespace ingress-basic \
  --version v0.13.0 \
  jetstack/cert-manager


echo "apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: abc@outlook.com
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: nginx" | kubectl apply -f -

# Demo application
helm repo add azure-samples https://azure-samples.github.io/helm-charts/
akshelloworldnamespace=aks-helloworld
kubectl create namespace $akshelloworldnamespace
helm install aks-helloworld azure-samples/aks-helloworld --namespace $akshelloworldnamespace 
helm install aks-helloworld-two azure-samples/aks-helloworld \
    --namespace $akshelloworldnamespace \
    --set title="AKS Ingress Demo" \
    --set serviceName="aks-helloworld-two"


AppDnsName=akshelloworld.rkim.ca

echo "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-world-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt
spec:
  tls:
  - hosts:
    - $AppDnsName
    secretName: tls-secret
  rules:
  - host: $AppDnsName
    http:
      paths:
      - backend:
          serviceName: aks-helloworld
          servicePort: 80
        path: /
      - backend:
          serviceName: aks-helloworld-two
          servicePort: 80
        path: /hello-world-two(/|$)(.*)
---
# apiVersion: extensions/v1beta1
# kind: Ingress
# metadata:
#   name: hello-world-ingress-static
#   annotations:
#     kubernetes.io/ingress.class: nginx
#     nginx.ingress.kubernetes.io/rewrite-target: /static/$2
#     cert-manager.io/cluster-issuer: letsencrypt
# spec:
#   tls:
#   - hosts:
#     - $AppDnsName
#     secretName: tls-secret
#   rules:
#   - host: $AppDnsName
#     http:
#       paths:
#       - backend:
#           serviceName: aks-helloworld
#           servicePort: 80
#         path: /static(/|$)(.*) " | kubectl apply --namespace $akshelloworldnamespace -f -

---

kubectl apply -f akshelloworld-hpa.yaml -n $akshelloworldnamespace #need hpa in same namespace as deployment or else <unknown> target


# Verify certificate
kubectl get certificate --namespace ingress-basic
kubectl get certificate --namespace $akshelloworldnamespace 
kubectl describe certificate tls-secret --namespace $akshelloworldnamespace 

kubectl get ingress -n ingress-basic
kubectl get ingress -n $akshelloworldnamespace 
kubectl get ingress -n $akshelloworldnamespace 
kubectl describe ingress -n $akshelloworldnamespace 
kubectl describe ingress hello-world-ingress -n $akshelloworldnamespace 
kubectl describe ingress hello-world-ingress-static -n $akshelloworldnamespace 

kubectl get pods -n ingress-basic
# kubectl logs -n ingress-basic nginx-nginx-ingress-controller-74bf9bd9f5-tzs7k
# kubectl logs -n ingress-basic nginx-nginx-ingress-controller-74bf9bd9f5-4vcc9