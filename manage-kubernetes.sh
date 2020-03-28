# manage-kubernetes.sh



# AKS
rgName='rkfunctionapp-sql'
aksName='rkaks'
location='canadacentral'

az aks list -g $rgName -o table 
az aks get-credentials -g $rgName -n $aksName

# Get all kubectl objects
kubectl get all -o wide | more

kubectl explain pods

# pods
kubectl get pods | grep Running

# external ip
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

# memory usage
kubectl top pod -A --no-headers=true | awk '{a[$1] += $4} END {for (c in a) printf "%-35s %s\n", c, a[c]}'

# Port forwarding
kubectl port-forward redis-izl09 6379

# Exec in container
kubectl exec redis-izl09 -- ls /

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