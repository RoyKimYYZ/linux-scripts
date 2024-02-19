# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/


cat > kustomization.yaml
curl -LO https://k8s.io/examples/application/wordpress/mysql-deployment.yaml
curl https://kubernetes.io/examples/application/wordpress/wordpress-deployment.yaml --output wordpress-deployment.yaml

cat <<EOF >./kustomization.yaml
secretGenerator:
- name: mysql-pass
  literals:
  - password=pw1234
EOF

cat <<EOF >>./kustomization.yaml
resources:
  - mysql-deployment.yaml
  - wordpress-deployment.yaml
EOF

cat <<EOF >>./kustomization.yaml
  - nginx-ingress-wordpress.yaml
EOF

cd ~/linux-scripts/deploy-wordpress/
namespaceName=wordpress
kubectl create namespace $namespaceName
kubectl label namespace $namespaceName istio-injection=enabled
kubectl config set-context --current --namespace=$namespaceName

kubectl apply -k ./ 

# verify
kubectl get secrets
kubectl get pvc
kubectl get pods
kubectl get svc


# Wordpress Prod Bitnami Helm Chart
# https://docs.bitnami.com/tutorials/deploy-custom-wordpress-production-helm/#step-1-define-configuration-values-for-the-bitnami-wordpress-helm-chart
curl -Lo values-production.yaml https://raw.githubusercontent.com/bitnami/charts/master/bitnami/wordpress/values-production.yaml
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create namespace wordpress-prod
helm install my-wordpress bitnami/wordpress  -f values-production.yaml -n wordpress-prod

echo "WordPress URL: http://wordpress.rkim.ca/"
   echo "$CLUSTER_IP  wordpress.rkim.ca" | sudo tee -a /etc/hosts
kubectl get all -n wordpress-prod

 helm repo add my-repo https://charts.bitnami.com/bitnami
helm install my-release my-repo/redis