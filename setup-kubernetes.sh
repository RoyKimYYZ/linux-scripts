# Setup Azure Kubernetes Service
# AKS variables
rgName='rkfunctionapp-sql'
aksName='rkaks'
location='canadacentral'

az aks get-credentials -g $rgName -n $aksName --admin --overwrite-existing
az aks browse -g $rgName -n $aksName
kubectl delete clusterrolebinding kubernetes-dashboard 
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard --insecure-skip-tls-verify 

