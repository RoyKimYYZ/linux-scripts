# Seige

sudo apt-get install -y siege

sudo apt --fix-broken install

siege -c 200 --time=30s http://20.151.27.249/ 

siege -c 255 --time=300s http://52.228.123.11/productpage