#!/bin/bash
# create and manage Azure Linux VM
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-cli

az account set -s 'Visual Studio Enterprise'
az account show
echo 'Resource group list'
az group list -o table
rgName='linux-demos'
location='canadacentral'
az group create --name $rgName --location $location
az group list -o table
vmName='rkLinux'
az vm create \
  --resource-group $rgName \
  --location $location \
  --name rkLinux \
  --image UbuntuLTS \az
  --admin-username azureuser \
  --generate-ssh-keys

az vm open-port --port 80 --resource-group $rgName --name $vmName
ssh azureuser@52.138.9.27

# bash script in VM
#sudo apt-get -y update
#sudo apt-get -y install nginx

az vm list -o table
rgName=LINUX-DEMOS
vmName=rkLinux
az vm list-ip-addresses --resource-group myResourceGroupVM --name myVM --output table
az vm deallocate -g $rgName -n $vmName
az vm show -n $vmName -g $rgName
az vm start -g $rgName -n $vmName 
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-disks
az vm create \
  --resource-group myResourceGroupDisk \
  --name myVM \
  --image UbuntuLTS \
  --size Standard_DS2_v2 \
  --generate-ssh-keys \
  --data-disk-sizes-gb 128 128
az vm disk attach \
    --resource-group myResourceGroupDisk \
    --vm-name myVM \
    --name myDataDisk \
    --size-gb 128 \
    --sku Premium_LRS \
    --new


az vm show -n $vmName -g $rgName
az vm list-ip-addresses -n $vmName -g $rgName # --query "{publicIpAddresses}" -o tsv
VMPublicIP=52.228.39.12
ssh azureuser@$VMPublicIP

# bash in vm
(echo n; echo p; echo 1; echo ; echo ; echo w) | sudo fdisk /dev/sdc

