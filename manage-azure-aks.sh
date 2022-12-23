#!/bin/bash

az login

# subscriptions
az account list -o table 
az account show -o table
subName="Visual Studio Enterprise"
App Service 
echo $subName
az account set --subscription "Visual Studio Enterprise"
az account set --subscription "App Service"


# resource group
az group list -o table

# AKS
rgName='aks-solution'
aksName='rkaks'
aksName='rkaks-demo'
location='canadacentral'

# Certificate Rotation
# https://learn.microsoft.com/en-us/azure/aks/certificate-rotation

az aks get-credentials -g $rgName -n $aksName --overwrite-existing
az aks rotate-certs -g $rgName -n $aksName
az aks show -g $rgName -n $aksName
rgName='linux-demos'
aksName='rkaks-vsent'
