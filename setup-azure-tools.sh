
### List of preferred tools ###

### Install PowerShell Core https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#ubuntu-1804
sudo apt-get update
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Update the list of products
sudo apt-get update
# Enable the "universe" repositories
sudo add-apt-repository universe

### Install AZ CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
# Install PowerShell
sudo apt-get install -y powershell
# Start PowerShell
pwsh
# Install Azure PowerShell
Install-Module -Name Az -AllowClobber -Scope CurrentUser
# Update Azure PowerShell
# Install-Module -Name Az -AllowClobber -Force

### Install Azure AD (Note: Not compatible with linux yet)
# Install-module AzureAD -Verbose
# Optional Workaround
# Register-PackageSource -Trusted -ProviderName 'PowerShellGet' -Name 'Posh Test Gallery' -Location https://www.poshtestgallery.com/api/v2/
# Install-Module -Name AzureAD.Standard.Preview

## Azure Resource Graph
# Add the Resource Graph extension to the Azure CLI environment
az extension add --name resource-graph
az extension list
az graph query -q 'Resources | project name, type | limit 5' -o table

### Install or Update Git
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-get update
sudo apt-get install git -y
git --version

# bash-completion package 
sudo apt install bash-completion

### Install Homebrew package manager
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
brew hey #verify