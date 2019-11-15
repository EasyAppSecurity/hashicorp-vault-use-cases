################# Setting environment variables ######################
#Skip if you've already done this in the current session
#Set env variable
#For Linux/MacOS
export VAULT_ADDR=http://127.0.0.1:8200
#For Windows
$env:VAULT_ADDR = "http://127.0.0.1:8200"

#As of now, the transit secrets engine supports the following key types (all key types also generate separate HMAC keys):

# - aes256-gcm96: AES-GCM with a 256-bit AES key and a 96-bit nonce; supports encryption, decryption, key derivation, and convergent encryption
# - chacha20-poly1305: ChaCha20-Poly1305 with a 256-bit key; supports encryption, decryption, key derivation, and convergent encryption
# - ed25519: Ed25519; supports signing, signature verification, and key derivation
# - ecdsa-p256: ECDSA using curve P256; supports signing and signature verification
# - rsa-2048: 2048-bit RSA key; supports encryption, decryption, signing, and signature verification
# - rsa-4096: 4096-bit RSA key; supports encryption, decryption, signing, and signature verification

################# Enable transit engine ######################
vault secrets enable transit

#Create a named encryption key
vault write -f transit/keys/eas-transit-key

#Encrypt some plaintext data using the /encrypt endpoint with a named key
#Assume that encrypted user/machine has a Vault token with the proper permission
#Text in base64 - ZXBhbV9zZWNyZXRfdG9fdHJhbnNpdA== - "eas_secret_to_transit"
vault write transit/encrypt/eas-transit-key plaintext=ZXBhbV9zZWNyZXRfdG9fdHJhbnNpdA==

#Decrypt a piece of data using the /decrypt endpoint with a named key
#Assume that unencrypted user/machine has a Vault token with the proper permission
vault write transit/decrypt/eas-transit-key ciphertext=vault:v1:u8YcNEwLZJWTnNa1PJbnhI/UNloR2Vj6kWXqvF5N8vGLm7jVEHiLZjbAxo1+gOvn04E=

#Rotate the underlying encryption key. This will generate a new encryption key and add it to the keyring for the named key
vault write -f transit/keys/eas-transit-key/rotate

#Old cipher text may be also decrypted (due to the use of a key ring)
vault write transit/decrypt/eas-transit-key ciphertext=vault:v1:u8YcNEwLZJWTnNa1PJbnhI/UNloR2Vj6kWXqvF5N8vGLm7jVEHiLZjbAxo1+gOvn04E=

#Upgrade already-encrypted data to a new key. 
#Vault will decrypt the value using the appropriate key in the keyring and then encrypted the resulting plaintext with the newest key in the keyring.
#This process does not reveal the plaintext data. As such, a Vault policy could grant almost an untrusted process the ability 
#to "rewrap" encrypted data, since the process would not be able to get access to the plaintext data.
vault write transit/rewrap/eas-transit-key ciphertext=vault:v1:u8YcNEwLZJWTnNa1PJbnhI/UNloR2Vj6kWXqvF5N8vGLm7jVEHiLZjbAxo1+gOvn04E=

#Delete the key
#Because this is a potentially catastrophic operation, the deletion_allowed tunable must be set in the key's /config endpoint.
#By default, when you create a new key, you can't delete it immediately, first you need to update the deletion_allowed boolean, as documented in the API docs to permit it being deleted.
vault delete transit/keys/eas-transit-key