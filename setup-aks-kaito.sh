# Microsoft Documentation https://learn.microsoft.com/en-us/azure/aks/ai-toolchain-operator

az login --use-device-code
PS1='\w \$ '

# AKS
rgName='aks-solution'
aksName='rkaksdev'
location='canadacentral'
subscriptionId=$(az account show --query "{subscriptionId:id}" --output tsv)

az account show --query "{subscription_name:name}"
az extension add --name aks-preview
# update option: az extension update --name aks-preview

az feature list --output table | grep ' Registered'
az feature register --namespace "Microsoft.ContainerService" --name "AIToolchainOperatorPreview" # Note applied to the current subscription
# verify the registration
az feature show --namespace "Microsoft.ContainerService" --name "AIToolchainOperatorPreview"

# Setup AI toolchain operator on existing cluster
az aks update --name ${aksName} \
        --resource-group ${rgName} \
        --enable-oidc-issuer \
        --enable-ai-toolchain-operator

# Export environment variables for the MC resource group, principal ID identity, and KAITO identity
export MC_RESOURCE_GROUP=$(az aks show --resource-group ${rgName} \
    --name ${aksName} \
    --query nodeResourceGroup \
    -o tsv)
export PRINCIPAL_ID=$(az identity show --name "ai-toolchain-operator-${aksName}" \
    --resource-group "${MC_RESOURCE_GROUP}" \
    --query 'principalId' \
    -o tsv)
export KAITO_IDENTITY_NAME="ai-toolchain-operator-${aksName}"

echo $MC_RESOURCE_GROUP
echo $PRINCIPAL_ID
echo $KAITO_IDENTITY_NAME

export AKS_OIDC_ISSUER=$(az aks show --resource-group "${rgName}" \
    --name "${aksName}" \
    --query "oidcIssuerProfile.issuerUrl" \
    -o tsv)

echo $AKS_OIDC_ISSUER

az role assignment create --role "Contributor" \
    --assignee "${PRINCIPAL_ID}" \
    --scope "/subscriptions/${subscriptionId}/resourcegroups/${rgName}"

# Create the federated identity credential between the managed identity, AKS OIDC issuer, and subject using the az identity federated-credential create command.

az identity federated-credential create --name "kaito-federated-identity" \
    --identity-name "${KAITO_IDENTITY_NAME}" \
    -g "${MC_RESOURCE_GROUP}" \
    --issuer "${AKS_OIDC_ISSUER}" \
    --subject system:serviceaccount:"kube-system:kaito-gpu-provisioner" \
    --audience api://AzureADTokenExchange

kubectl get deployment/kaito-gpu-provisioner -n kube-system
kubectl rollout restart deployment/kaito-gpu-provisioner -n kube-system

# Verify that the deployment is running using the kubectl get command:
kubectl get deployment -n kube-system | grep kaito

curl -sb -H "Accept: application/json" https://raw.githubusercontent.com/Azure/kaito/main/examples/kaito_workspace_falcon_7b-instruct.yaml

# Deploy the Falcon 7B-instruct model from the KAITO model repository 
kubectl apply -f https://raw.githubusercontent.com/Azure/kaito/main/examples/inference/kaito_workspace_falcon_7b-instruct.yaml
# Standard_NC8as_T4_v3

kubectl config view --minify --output 'jsonpath={..namespace}'
currentNamespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
echo "Current kubectl namespace: $currentNamespace"

# Track the live resource changes in your workspace 
# machine readiness can take up to 10 minutes, and workspace readiness up to 20 minutes.
kubectl get workspace workspace-falcon-7b-instruct -w

export SERVICE_IP=$(kubectl get svc workspace-falcon-7b-instruct -o jsonpath='{.spec.clusterIP}')
echo $SERVICE_IP
export SERVICE_PUBLIC_IP=$(kubectl get svc workspace-falcon-7b-instruct-service -o jsonpath='{.spec.external-IP}')
export SERVICE_PUBLIC_IP="4.172.68.127"


export AI_PROMPT="when do the next solar eclipse occure and where?"

export AI_PROMPT="Describe an Artificial Intelligence inference model and what is its use?"
export AI_PROMPT="What is the capital of Canada?"
export AI_PROMPT="What is meaning of life?"

echo $AI_PROMPT
kubectl run -it --rm --restart=Never curl --image=curlimages/curl -- curl -X POST http://$SERVICE_IP/chat -H "accept: application/json" -H "Content-Type: application/json" \
    -d "{\"prompt\":\"$AI_PROMPT\"}"

echo $SERVICE_PUBLIC_IP
curl -X POST http://$SERVICE_PUBLIC_IP/chat -H "accept: application/json" -H "Content-Type: application/json" \
    -d "{\"prompt\":\"$AI_PROMPT\"}"
    

kubectl apply -f https://raw.githubusercontent.com/Azure/kaito/main/examples/inference/kaito_workspace_falcon_7b-instruct.yaml
# Standard_NC8as_T4_v3

# public k8s service
kubectl apply -f ./falcon-7b-instruct-service.yaml
kubectl delete -f ./falcon-7b-instruct-service.yaml


kubectl delete pod curl

kubectl delete -f https://raw.githubusercontent.com/Azure/kaito/main/examples/inference/kaito_workspace_falcon_7b-instruct.yaml

