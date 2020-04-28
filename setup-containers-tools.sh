##############################################
# Install Docker
sudo apt-get update
sudo apt install docker.io
service --status-all
sudo service docker start
sudo service docker status
sudo /etc/init.d/docker start #sudo systemctl start docker
sudo systemctl enable docker
docker --version
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
sudo apt install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
# https://blog.jayway.com/2017/04/19/running-docker-on-bash-on-windows/
export DOCKER_HOST=tcp://192.168.0.102:2375  # your Docker IP
export DOCKER_CERT_PATH=/mnt/c/Users/rkim/.docker/machine/certs
export DOCKER_TLS_VERIFY=0
docker -H tcp://0.0.0.0:2375 images

# verify
sudo docker run hello-world

#############################################
# Install kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl


# Kubectl autocompletion
# https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion

sudo apt-get install bash-completion
type _init_completion # may need to reload shell
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >>~/.bashrc # set alias


#######
# HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# note: helm installed into /usr/local/bin/helm
  