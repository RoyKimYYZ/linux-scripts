#!/bin/bash
# manage-kubernetes.sh

az account show -o table

# AKS
rgName='linux-demos'
aksName='rkaks-demo2'
location='canadacentral'

# create AKS cluster through the portal

# testing service principal
# {
#   "appId": "fe6efe77-a0ab-47e5-bc1e-1c1a0b7ccf0c",
#   "name": "http://azure-cli-2019-07-23-02-49-11",
#   "password": "543ab9f1-fcd3-4a3a-9623-da7a67ccb4fc",
# }

az aks list -g $rgName -o table 
az aks get-credentials -g $rgName -n $aksName --admin
az aks browse -g $rgName -n $aksName
# http://localhost:8002/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default


## Kubernetes dashboard
kubectl delete clusterrolebinding kubernetes-dashboard 
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard --insecure-skip-tls-verify 
kubectl create clusterrolebinding serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin --group=system:serviceaccounts

kubectl get secrets -n kube-system | grep dashboard-token 
kubectl get secrets -n kube-system -o json
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
echo $TOKEN
curl http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/login


# Get all kubectl objects
kubectl get all -o wide | more

# Local Context
kubectl config current-context
kubectl config get-contexts 

# namespaces
kubectl get namespaces

# nodes
kubectl get nodes | grep "Ready"

# pods
kubectl get pods
kubectl get pods | grep Running

# check helm version
helm version
helm list --all-namespaces


# istio
################################

# install istio tools
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.5.1
export PATH=$PWD/bin:$PATH #note: not global across terminals
istioctl version

$istioNamespace = 'istio-system'
# deploy istio
# pre-check readiness
istioctl verify-install -i $istioNamespace

# istioctl manifest apply --set profile=demo

# OR 

istioctl manifest apply \
  --set values.kiali.enabled=true \
  --set values.grafana.enabled=true \
  --set values.tracing.enabled=true \


KIALI_USERNAME=$( echo -n admin | tr -d '\n' | base64)
KIALI_PASSPHRASE=$( echo -n admin | tr -d '\n' | base64)

echo $KIALI_USERNAME
echo $KIALI_PASSPHRASE
KIALI_USERNAME=$(read -p 'Kiali Username: ' uval && echo -n $uval | base64)
KIALI_PASSPHRASE=$(read -sp 'Kiali Passphrase: ' pval && echo -n $pval | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: $NAMESPACE
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF

echo "apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE" | kubectl apply -f -

kubectl apply -f kiali-secret.yaml

kubectl get secret -n istio-system
kubectl delete secret kiali -n istio-system

kubectl get secret -n istio-system kiali -o jsonpath='{.data.passphrase}' | base64 -d | wc -l
kubectl get secret -n istio-system kiali -o jsonpath='{.data.username}' | base64 -d | wc -l

# alternate install
#  bash <(curl -L https://kiali.io/getLatestKialiOperator) --accessible-namespaces '**'


istioctl dashboard kiali

cd istio-1.5.1
export PATH=$PWD/bin:$PATH #note: not global across terminals
istioctl dashboard prometheus

GRAFANA_USERNAME=$( echo "admin" | base64 )
GRAFANA_PASSPHRASE=$( echo "admin" | base64 )

# Create grafa username and password secrets
echo "apiVersion: v1
kind: Secret
metadata:
  name: grafana
  namespace: istio-system
  labels:
    app: grafana
type: Opaque
data:
  username: $GRAFANA_USERNAME
  passphrase: $GRAFANA_PASSPHRASE" | kubectl apply -f -

export PATH=$PWD/bin:$PATH #note: not global across terminals
istioctl dashboard grafana
cd /home/rkim
git clone https://github.com/istio/istio.git


# Deploy Bookinfo Application
# https://istio.io/docs/examples/bookinfo/
kubectl label namespace default istio-injection=enabled
cd ~/istio-1.5.1
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateway

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo $GATEWAY_URL
curl -s http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>"

kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml
kubectl get destinationrules -o yaml


echo "kind: HorizontalPodAutoscaler
apiVersion: autoscaling/v2beta2
metadata:
  name: product-page-hpa
spec:
  scaleTargetRef:
    # point the HPA at the sample application
    # you created above
    apiVersion: apps/v1
    kind: Deployment
    name: proeuctpage-v1
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: packets-per-second
      target:
        type: AverageValue
        averageValue: 1k
  - type: Object
    object:
      metric:
        name: requests-per-second
      describedObject:
        apiVersion: networking.k8s.io/v1beta1
        kind: Ingress
        name: ingressgateway
      target:
        type: Value
        value: 10k" | kubectl apply -f -


# Helm charts in public repos
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm search repo stable

# NGINX ingress
#kubect create namespace nginx-ingress
helm install my-nginx-ingress stable/nginx-ingress  \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

kubectl --namespace default get services -o wide -w my-nginx-ingress-controller

# Guestbook App

kubectl apply -f https://raw.githubusercontent.com/kubernetes/examples/master/guestbook/all-in-one/guestbook-all-in-one.yaml

echo "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: guestbook-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: 'false'
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: frontend
          servicePort: 80" | kubectl apply -f -

export ingressControllerName='my-nginx-ingress-controller'
kubectl get services $ingressControllerName -n default -o json | jq .status.loadBalancer.ingress[0].ip

# show the public ip created

# Redis cache
###############
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo bitnami
helm install redis-release bitnami/redis

# Prometheus Operator
#####################

kubectl create namespace monitoring
helm install prometheus-operator -f ./prometheus-config-values.yaml -n monitoring stable/prometheus-operator \
--set prometheusOperator.createCustomResource=false

# Azure Container Registry
ACR_NAME=acrlivedemo
az acr create --resource-group $rgName --name $ACR_NAME --sku Standard --location canadacentral
# Get the id of the service principal configured for AKS
CLIENT_ID=$(az aks show --resource-group $rgName --name $aksName --query "servicePrincipalProfile.clientId" --output tsv)
# Get the ACR registry resource id
ACR_ID=$(az acr show --name $ACR_NAME --resource-group $rgName --query "id" --output tsv)
# Create role assignment
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID

# Services that may have external IP
kubectl get services -A | grep LoadBalancer

# eshopContainers App
#####################
cd /
git clone https://github.com/dotnet-architecture/eShopOnContainers.git
cd /deploy/k8s/helm
chmod 700 deploy-all.sh
./deploy-all.sh -aksName $aksName -aksRg $rgName -imageTag dev -useMesh $false
pwsh
./deploy-all.ps1 -externalDns aks -aksName $aksName -aksRg $rgName -imageTag dev -useMesh $false

# memory usage
kubectl top pod -A | awk '{a[$1] += $4} END {for (c in a) printf "%-35s %s\n", c, a[c]}'

# Port forwarding
kubectl port-forward redis-izl09 6379

# Exec in container
kubectl exec redis-izl09 -- ls /

# Kubernetes config
kubectl config view


# Explore the API with TOKEN
curl -X GET $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure

# Exec / SSH
kubectl exec -it  azure-vote-front-66966b9dd7-9lhtx -- /bin/bash

# troubleshooting
###################
kubectl logs -f pod_name -c my-container

# Miscelaneous
###################


# base64
keyBase64=$(echo "some key" | base64)
echo $keyBase64

# custom columns for output
kubectl get po --all-namespaces -o=custom-columns=NAME:.metadata.name,USER:.metadata.user,VERSION:.metadata.version

# watch
watch kubectl top nodes
watch kubectl top pods

# k8s documentation
kubectl explain pods

# functions; 
function helloworld() { echo "hello wolrd $@"; command kubectl}


# sed example
echo 'hello world ' | sed 's/hello/world/'
https://kubernetes.io/docs/reference/kubectl/cheatsheet/#updating-resources
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

