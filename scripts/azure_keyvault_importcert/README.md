
#  Azure Key Vault Import Certificate

## Description

This script is used to import private key and certificate, in the form of a PKCS#12 keystore, into Azure Key Vault. The Key Vault REST API is used for the import.

Relevant Azure documentation: https://docs.microsoft.com/en-us/rest/api/keyvault/importcertificate/importcertificate

## Usage

Run the script to get help on arguments needed.
```
./keyVault_ImportCert.sh
```

Example command to import keystore 'keystore.p12' that is protected with the password 'p12password'. The imported certificate and private key will be accessible with the friendly name/alias 'alias' in Key Vault.
```
./keyVault_ImportCert.sh -t example.com -i 27f5ec0d6-81ee-72cd-a0f3-9db510139971 -p azure_client_password -n example-keyvault -s alias -f keystore.p12 -c p12password
```

### Using from EJBCA

Issuing P12 keystores in batch from EJBCA is a common task that can be done through several ways. During the generation process this script can be called to populate Azure Key Vault with the issued certificates and private keys.
You can also use this script to test and get the REST API commands to call directly to Key Vault form within the keystore generation process.

