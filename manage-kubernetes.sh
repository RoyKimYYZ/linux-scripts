#!/bin/bash
# manage-kubernetes.sh

az account show -o table

# AKS
rgName='rkfunctionapp-sql'
aksName='rkaks'
rgName='linux-demos'
aksName='rkakslivedemo'
location='canadacentral'

az aks list -g $rgName -o table 
az aks get-credentials -g $rgName -n $aksName --admin
az aks browse -g $rgName -n $aksName

# Get all kubectl objects
kubectl get all -o wide | more

# Local Context
kubectl config current-context
kubectl config get-contexts 
kubectl config get-contexts -o name 

# namespaces
kubectl get namespaces

# nodes
kubectl get nodes | grep "Ready"

# pods
kubectl get pods
kubectl get pods | grep Running
# sorty by restart count
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# external ip
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
export ingressControllerName='my-nginx-ingress-controller'
kubectl get services $ingressControllerName -n default -o json | jq .status.loadBalancer.ingress[0].ip
# Services that may have external IP
kubectl get services -A | grep LoadBalancer

# services

# hpa
kubectl get hpa 

# persistent volume claim

# persistent volume

# replicasets
kubectl get replicasets



# memory usage
kubectl top pod -A | awk '{a[$1] += $4} END {for (c in a) printf "%-35s %s\n", c, a[c]}'

# Port forwarding
kubectl port-forward redis-izl09 6379

# Exec in container
kubectl exec redis-izl09 -- ls /

# Kubernetes config
kubectl config view

## Kubernetes dashboard
kubectl get secrets -n kube-system | grep dashboard-token 
kubectl get secrets -n kube-system -o json
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
echo $TOKEN

# Explore the API with TOKEN
curl -X GET $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure
kubectl describe secret kubernetes-dashboard-token-pqcrg -n kube-system

kubectl exec -it  azure-vote-front-66966b9dd7-9lhtx -- /bin/bash

# troubleshooting
###################
kubectl logs -f pod_name -c my-container

# cleanup port forwarding
killall kubectl

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

