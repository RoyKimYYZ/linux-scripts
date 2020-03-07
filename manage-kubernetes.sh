# manage-kubernetes.sh

# Install kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# AKS
rgName='rkfunctionapp-sql'
aksName='rkaks'
location='canadacentral'

az aks get-credentials -g $rgName -n $aksName

# 
kubectl get all -o wide | more

# pods
kubectl get pods | grep Running

# external ip
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'



# troubleshooting