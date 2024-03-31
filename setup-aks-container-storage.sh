# Microsoft Documentation: https://learn.microsoft.com/en-us/azure/storage/container-storage/container-storage-aks-quickstart?source=recommendations

az login --use-device-code

PS1='\w \$ '

# AKS
rgName='aks-solution'
aksName='rkaksdev'
location='canadacentral'

az aks nodepool list --resource-group $rgName --cluster-name $aksName -o table

az aks update -n $aksName -g $rgName --enable-azure-container-storage <storage-pool-type> --azure-container-storage-nodepools <comma separated values of nodepool names>
