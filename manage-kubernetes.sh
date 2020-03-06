#manager-kubernetes.sh

# pods
kubectl get pods | grep ready

# external ip
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
