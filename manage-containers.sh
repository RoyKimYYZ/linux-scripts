
# Install Docker
sudo apt install docker.io
service --status-all
sudo service docker start
sudo service docker status
sudo systemctl start docker
sudo systemctl enable docker
docker --version
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
sudo apt install apt-transport-https ca-certificates curl software-properties-commony
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo systemctl status docker


# verify
sudo docker run hello-world

# Install kubectl
sudo apt-get install -y kubectl    