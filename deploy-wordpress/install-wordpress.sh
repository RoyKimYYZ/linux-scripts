# https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/


cat > kustomization.yaml
curl -LO https://k8s.io/examples/application/wordpress/mysql-deployment.yaml
curl https://kubernetes.io/examples/application/wordpress/wordpress-deployment.yaml --output wordpress-deployment.yaml

cat <<EOF >./kustomization.yaml
secretGenerator:
- name: mysql-pass
  literals:
  - password=YOUR_PASSWORD
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

wpadmin
wpress
#Uvj9d#6H0zJPgvnS^