################# Setting environment variables ######################
#Skip if you've already done this in the current session
#Set env variable
#For Linux/MacOS
export VAULT_ADDR=http://127.0.0.1:8200
#For Windows
$env:VAULT_ADDR = "http://127.0.0.1:8200"

################# Enable database secrets engine ######################
#You are going to need an instance of MySQL running somewhere.  I use
#the Bitnami image on Azure, but you could do it locally instead.  You
#will need to open port 3306 on the remote instance to let Vault talk
#to it properly

#Enable the database secrets engine
vault secrets enable database

#Change <localhost> to your public IP address if you're using a remote
#MySQL instance

#SSH into the MySQL instance and run the follow commands.

#Configure MySQL roles and permissions
mysql -u root -p
CREATE ROLE 'eas-dev';
CREATE USER 'eas-vault'@'localhost' IDENTIFIED BY 'AsYcUdOP426i';
CREATE DATABASE eas_devdb;
GRANT ALL ON *.* TO 'eas-vault'@'localhost';
GRANT GRANT OPTION ON eas_devdb.* TO 'eas-vault'@'localhost';

#Change <localhost> to the IP address of the MySQL server
#Configure the MySQL plugin
#Oneline
################################################################
# vault write database/config/eas-mysql-database plugin_name=mysql-database-plugin connection_url="{{username}}:{{password}}@tcp(localhost:3306)/" allowed_roles="eas-dev" username="eas-vault" password="AsYcUdOP426i"
################################################################
vault write database/config/eas-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(localhost:3306)/" \
    allowed_roles="eas-dev" \
    username="eas-vault" \
    password="AsYcUdOP426i"

#Configure a role to be used
################################################################
# vault write database/config/eas-mysql-database plugin_name=mysql-database-plugin connection_url="{{username}}:{{password}}@tcp(localhost:3306)/" allowed_roles="eas-dev" username="eas-vault" password="AsYcUdOP426i"
################################################################
# default_ttl - default amount of time the credentials will be valid
# max_ttl - maximum amount of time before has to be revnewed (lease cant exceed 24 hours)
vault write database/roles/eas-dev \
    db_name=eas-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON eas_devdb.* TO '{{name}}'@'%';" \
    default_ttl="1h" \ 
    max_ttl="24h"

#Generate credentials on the DB from the role
vault read database/creds/eas-dev

#Validate that the user has been created on MySQL and that the proper
#permissions have been applied
SELECT User FROM mysql.user;
SHOW GRANTS FOR 'v-root-eas-dev-Uc5A66K18m5nhI5sf';

#Renew the lease
vault lease renew -increment=3600 database/creds/eas-dev/fPdn35YfP2SqZ3XtsDMEkOm2

vault lease renew -increment=96400 database/creds/eas-dev/fPdn35YfP2SqZ3XtsDMEkOm2

#Revoke the lease
vault lease revoke database/creds/eas-dev/fPdn35YfP2SqZ3XtsDMEkOm2

