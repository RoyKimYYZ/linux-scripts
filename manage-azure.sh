az login

# subscriptions
az account list -o table
az account show -o table
subName="Visual Studio Enterprise"
echo $subName
az account set --subscription "Visual Studio Enterprise"


# resource group
az group list -o table