# Nginx Ingress Automatic TLS
# https://docs.microsoft.com/en-us/azure/aks/ingress-tls

# AKS
rgName='linux-demos'
aksName='rkaks-demo'
location='canadacentral'

# Create a namespace for your ingress resources
kubectl create namespace ingress-basic

# Add the official stable repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Use Helm to deploy an NGINX ingress controller
helm install nginx stable/nginx-ingress \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

kubectl get service -l app=nginx-ingress --namespace ingress-basic
kubectl get service nginx-nginx-ingress-controller --namespace ingress-basic

# Public IP address of your ingress controller
publicIP='20.151.28.63'

## Add an A record to your DNS zone ##

# Set A record to GoDaddy DNS 
# OR
# Name to associate with public IP address
DNSNAME="demo-aks-ingress"
# Get the resource-id of the public ip
PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)
# Update public ip address with DNS name
az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME
# Display the FQDN
az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv

## Install cert-manager

# Install the CustomResourceDefinition resources separately
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml

# Label the ingress-basic namespace to disable resource validation
kubectl label namespace ingress-basic cert-manager.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install \
  cert-manager \
  --namespace ingress-basic \
  --version v0.13.0 \
  jetstack/cert-manager


echo "apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: abc@outlook.com
    privateKeySecretRef:
      name: letsencrypt
    solvers:
    - http01:
        ingress:
          class: nginx" | kubectl apply -f -

# Demo application
helm repo add azure-samples https://azure-samples.github.io/helm-charts/
namespace=aks-helloworld-app
kubectl create namespace $namespace
helm install aks-helloworld azure-samples/aks-helloworld --namespace $namespace
helm install aks-helloworld-two azure-samples/aks-helloworld \
    --namespace $namespace \
    --set title="AKS Ingress Demo" \
    --set serviceName="aks-helloworld-two"


AppDnsName=akshelloworld.rkim.ca

echo "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-world-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt
spec:
  tls:
  - hosts:
    - $AppDnsName
    secretName: tls-secret
  rules:
  - host: $AppDnsName
    http:
      paths:
      - backend:
          serviceName: aks-helloworld
          servicePort: 80
        path: /
      - backend:
          serviceName: aks-helloworld-two
          servicePort: 80
        path: /hello-world-two(/|$)(.*)
---
# apiVersion: extensions/v1beta1
# kind: Ingress
# metadata:
#   name: hello-world-ingress-static
#   annotations:
#     kubernetes.io/ingress.class: nginx
#     nginx.ingress.kubernetes.io/rewrite-target: /static/$2
#     cert-manager.io/cluster-issuer: letsencrypt
# spec:
#   tls:
#   - hosts:
#     - $AppDnsName
#     secretName: tls-secret
#   rules:
#   - host: $AppDnsName
#     http:
#       paths:
#       - backend:
#           serviceName: aks-helloworld
#           servicePort: 80
#         path: /static(/|$)(.*) " | kubectl apply --namespace aks-helloworld-app -f -

---

echo "kind: Service
apiVersion: v1
metadata:
  name: aks-helloworld2
spec:
  type: ExternalName
  externalName: aks-helloworld.aks-hellworld-app.svc.cluster.local
  ports:
  - port: 80 " | kubectl apply --namespace aks-helloworld-app -f -

# Verify certificate
kubectl get certificate --namespace ingress-basic
kubectl get certificate --namespace aks-helloworld-app
kubectl describe certificate tls-secret --namespace aks-helloworld-app

kubectl get ingress -n ingress-basic
kubectl get ingress -n aks-helloworld-app
kubectl get ingress -n aks-helloworld-app
kubectl describe ingress -n aks-helloworld-app
kubectl describe ingress hello-world-ingress -n aks-helloworld-app
kubectl describe ingress hello-world-ingress-static -n aks-helloworld-app

kubectl get pods -n ingress-basic
kubectl logs -n ingress-basic nginx-nginx-ingress-controller-74bf9bd9f5-tzs7k
kubectl logs -n ingress-basic nginx-nginx-ingress-controller-74bf9bd9f5-4vcc9