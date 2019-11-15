################# Installing Vault ##########################

#For Windows
$vaultVersion = "1.0.1"
Invoke-WebRequest -Uri https://releases.hashicorp.com/vault/$vaultVersion/vault_$($vaultVersion)_windows_amd64.zip -OutFile .\vault_$($vaultVersion)_windows_amd64.zip
Expand-Archive .\vault_$($vaultVersion)_windows_amd64.zip
cd .\vault_$($vaultVersion)_windows_amd64
#Copy vault executable to a location include in your path variable

#For Linux
VAULT_VERSION="1.0.1"
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

#Install unzip if necessary
sudo apt install unzip -y
unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo chown root:root vault
sudo mv vault /usr/local/bin/

################# Starting the Dev server ######################

#Start the Dev server for vault
vault server -dev 

#Set env variable
#For Linux/MacOS
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=AddYourVaultTokenHere

#For Windows
$env:VAULT_ADDR = "http://127.0.0.1:8200"
$env:VAULT_TOKEN = "AddYourVaultTokenHere"
$headers = @{
    "X-Vault-Token" = $env:VAULT_TOKEN
}

#Log into the vault server
#Use the root token from the output
vault login

############## Secret Lifecycle Research ######################
vault kv put secret/eas-ssdl/eas_secret secret_test=1

vault kv get secret/eas-ssdl/eas_secret

vault kv put secret/eas-ssdl/eas_secret secret_test=2

vault kv get secret/eas-ssdl/eas_secret

vault kv delete secret/eas-ssdl/eas_secret

vault kv get secret/eas-ssdl/eas_secret

vault kv get -version=1 secret/eas-ssdl/eas_secret

vault kv undelete -versions=2 secret/eas-ssdl/eas_secret

##No versions provided, use the "-versions" flag to specify the version to destroy.
vault kv delete secret/eas-ssdl/eas_secret
vault kv destroy secret/eas_secret

vault kv destroy -versions=2 secret/eas-ssdl/eas_secret
vault kv destroy -versions=1 secret/eas-ssdl/eas_secret

##Not working
vault kv undelete -versions=2 secret/eas-ssdl/eas_secret

##Metadata Delete
vault kv metadata delete secret/eas-ssdl/eas_secret