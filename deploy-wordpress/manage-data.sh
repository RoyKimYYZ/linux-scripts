# mysql

# SSH / Terminal into mysql container

# connecto to mysql server
mysql -u root -p
# provide password defined in deployment yaml or in db password secret

mysql> 

SELECT USER(),CURRENT_USER();

SHOW DATABASES;

select table_schema as database_name,
    table_name
from information_schema.tables
where table_type = 'BASE TABLE'
    and table_schema not in ('information_schema','mysql',
                             'performance_schema','sys')
order by database_name, table_name;

use <databasename>;

select * from <table name>;