# MySQL
sudo app-get update
sudo apt-get install mysql-client -y
mysql -h HOST -P PORT_NUMBER -u USERNAME -p

# Sql Package
# https://docs.microsoft.com/en-us/sql/tools/sqlpackage-download?view=sql-server-ver15#get-sqlpackage-net-core-for-linux
sudo apt-get install libunwind8
lsb_release -a
# install the libicu library based on the Ubuntu version
sudo apt-get install libicu60      # for 18.x

# Install mssql tools for ubuntu
# https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
sudo apt-get update 
sudo apt-get install mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

# Ubuntu 20.04
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/19.10/prod.list > /etc/apt/sources.list.d/mssql-release.list
sudo apt update 
sudo apt install libodbc1
sudo ACCEPT_EULA=Y apt install mssql-tools unixodbc-dev msodbcsql17 unixodbc odbcinst1debian2



sqlServerName='rkaks-sqlserver'
sqlDatabaseName='rkaksDB'
userName='roy@roykim.ca'
echo -n Password: 
read -s password
sqlcmd -S $sqlServerName.database.windows.net -d $sqlDatabaseName -U $userName -P 'Winterwinter09 -G -l 30
