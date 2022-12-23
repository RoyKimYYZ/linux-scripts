#!/bin/bash
# manage-kubernetes.sh

az account list -o table 
az account show -o table
az account set --subscription 'app service'
# AKS
rgName='linux-demos'
aksName='rkaks-vsent'
rgName='aks-solution'
aksName='rkaks'
aksName='rkaksdev'
aksName='rkaks-demo'


location='canadacentral'

az aks list -g $rgName -o table 
az aks get-credentials -g $rgName -n $aksName --admin --overwrite-existing
az aks get-credentials -g aks-solution -n rkaksdev 

az aks update -g $rgName -n $aksName --aad-admin-group-object-ids d09929d2-0845-4025-a48b-86cd1193f9f3 --enable-local
az aks update -g <resource-group> -n <cluster-name> --enable-aad --aad-admin-group-object-ids <aad-group-id> --enable-local

SP_ID=$(az aks show --resource-group $rgName --name $aksName  --query servicePrincipalProfile.clientId -o tsv)
echo $SP_ID
SP_SECRET=$(az ad sp credential reset --id "$SP_ID" --query password -o tsv)
az resource update --ids /subscriptions/ed4bb153-37db-4f9e-99b0-dc0f00cd8be3/resourceGroups/aks-solution/providers/Microsoft.ContainerService/managedClusters/rkaks-demo




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
kubectl get hpa -n voting
kubectl describe hpa -n voting
kubectl get hpa -n voting

kubectl describe hpa -n bookinfo
kubectl get hpa -n bookinfo
kubectl describe hpa -n default
kubectl get hpa -n default
kubectl describe hpa -n aks-helloworld
kubectl get hpa -n aks-helloworld
kubectl top pods -n aks-helloworld

kubectl describe hpa -n guestbook-app
kubectl get hpa -n guestbook-app
kubectl top pods -n guestbook-app

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
kubectl cluster-info # GET API SERVER URL
APISERVER=https://rkaks-demo-aks-solution-ed4bb1-e6135a9e.hcp.canadacentral.azmk8s.io:443
curl -X GET $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure
kubectl describe secret kubernetes-dashboard-token-pqcrg -n kube-system

kubectl get clusterrolebinding kubernetes-dashboard
kubectl describe clusterrolebinding kubernetes-dashboard

kubectl delete clusterrolebinding kubernetes-dashboard
# include user 'clusterUser'
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard --user=clusterUser
kubectl describe clusterrolebinding kubernetes-dashboard

kubectl exec -it  azure-vote-front-66966b9dd7-9lhtx -- /bin/bash

# troubleshooting
###################
kubectl logs -f pod_name -c my-container

kubectl run -i --tty busybox --image=busybox --restart=Never -- sh   
kubectl run -i --tty busybox --image=yauritux/busybox-curl --restart=Never -- sh   
kubectl exec -it busybox2 -- opkg-install curl

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

# autoscaler-status
kubectl describe configmap --namespace kube-system cluster-autoscaler-status

# functions; 
function helloworld() { echo "hello wolrd $@"; command kubectl}


# sed example
echo 'hello world ' | sed 's/hello/world/'
https://kubernetes.io/docs/reference/kubectl/cheatsheet/#updating-resources
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

# openssl certificate
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt
openssl req -out httpbin.example.com.csr -newkey rsa:2048 -nodes -keyout httpbin.example.com.key -subj "/CN=httpbin.example.com/O=httpbin organization"
openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in httpbin.example.com.csr -out httpbin.example.com.crt


