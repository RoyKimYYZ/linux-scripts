
# Start a test pod in the cluster:
kubectl run -it --rm aks-ssh --image=debian:stable

# After the test pod is running, you will gain access to the pod.
# Then you can run the following commands:
apt-get update -y && apt-get install dnsutils -y && apt-get install curl -y

# After the packages are installed, test the connectivity to the application pod:
curl -Iv http://<pod-ip-address>:<port>