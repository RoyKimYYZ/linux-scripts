az login --use-device-code

PS1='\w \$ '

# AKS
rgName='aks-solution'
aksName='rkaks'
aksName='rkaksdev'
location='canadacentral'

az aks get-credentials -g $rgName -n rkaksdev --admin
az aks get-credentials -g aks-solution -n rkaksdev --admin


# Get the current AKS cluster version
az aks show --resource-group $rgName --name $aksName --query kubernetesVersion -o tsv

# Get available AKS versions
az aks get-versions --location $location -o table
az aks get-upgrades --resource-group $rgName --name $aksName -o table


nodepoolName='agentpool'

# Check node image version 
az aks nodepool show --name $nodepoolName --query nodeImageVersion --resource-group $rgName --cluster-name $aksName 
az aks nodepool get-upgrades --nodepool-name $nodepoolName --resource-group $rgName --cluster-name $aksName -o table

# Upgrade a specific node pool
az aks nodepool upgrade --name $nodepoolName --resource-group $rgName --cluster-name $aksName --node-image-only

kubectl get nodes \
-o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubernetes\.azure\.com\/node-image-version}{"\n"}{end}'

az aks nodepool show --name $nodepoolName --resource-group $rgName --cluster-name $aksName -o table

# check the current nodeOsUpgradeChannel value on a cluster
az aks show --resource-group $rgName --name $aksName --query "autoUpgradeProfile"

kubectl get events

az aks install-cli

# https://github.com/Azure/kubelogin#setup
# https://zaidcloud.wordpress.com/2023/05/20/install-kubelogin-on-windows-subsystem-for-linux-wsl/

VERSION=$(curl --silent "https://api.github.com/repos/int128/kubelogin/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -LO "https://github.com/int128/kubelogin/releases/download/$VERSION/kubelogin_linux_amd64.zip"
unzip kubelogin_linux_amd64.zip
chmod +x kubelogin
export PATH=$PATH:"/usr/local/bin"
echo $PATH | more
which kubelogin

more ~/.kube/config
export KUBECONFIG=~/.kube/config
kubelogin convert-kubeconfig

# asdf
$HOME/.asdf/bin/asdf
$HOME/.asdf/bin/asdf plugin add kubelogin
$HOME/.asdf/bin/asdf global kubelogin latest
/home/rkadmin/.asdf/shims/kubelogin convert-kubeconfig -l azurecli
export PATH=$PATH:"/home/rkadmin/.asdf/shims/"

az aks update --resource-group $rgName --name $aksName --enable-oidc-issuer 
az aks show --resource-group $rgName --name $aksName --query "oidcIssuerProfile.issuerUrl" -otsv

az aks start --resource-group $rgName --name $aksName
az resource update --name rkaks-demo --namespace Microsoft.ContainerService --resource-group $rgName  --resource-type ManagedClusters 


export KUBECONFIG=$HOME/.kube/config
kubelogin convert-kubeconfig -l azurecli


kubectl get pdb -A
kubectl get poddisruptionbudget istio-egressgateway -n istio-system -o yaml
kubectl patch poddisruptionbudget istio-egressgateway --type='json' -p='[{"op": "replace", "path": "/spec/disruptionsAllowed", "value": 2}]' -n istio-system

# AKS version is 1.26.10
az extension remove --name aks-preview
az extension add --name aks-preview
az extension list-available --output table
az upgrade --output table


az aks update --resource-group $rgName --name $aksName --enable-oidc-issuer 
az aks show --resource-group $rgName --name $aksName --query "oidcIssuerProfile.issuerUrl" -otsv
