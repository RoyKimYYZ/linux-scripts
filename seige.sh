# Seige

sudo apt-get install -y siege

sudo apt --fix-broken install

siege -c 100 --time=90s http://20.151.27.249/ 

siege -c 100 --time=900s http://bookinfo.rkim.ca/productpage

siege -c 250 --time=900s http://akshelloworld.rkim.ca

siege -c 250 --time=900s http://voting.rkim.ca

siege -c 250 --time=990s https://guestbook.rkim.ca/guestbook.php?cmd=set&key=messages&value=,,,,Roy,Roy1,Roy2,Roy3