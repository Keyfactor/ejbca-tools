#!/bin/bash

EXPORT_CERTIFICATE=false
VAULT_API_VERSION=7.1

help () {
  echo "Usage: `basename $0` options"
  echo "-c : Certificate file (p12) password that was used to encrypt the private key"
  echo "-e : Enable export of Certificate file after importing into Key Vault"
  echo "-f : Certificate file to upload to Key Vault ('cert1.p12') The file must be a p12 in binary format"
  echo "-i : Azure Client ID used to access Key Vault"
  echo "-n : Key Vault Name which is used to create the URL to access the Key Vault (https://$VAULT_NAME.vault.azure.net/certificates/)"
  echo "-p : Azure Password used to authenticate to Azure and get a token for further interaction with Key Vault"
  echo "-s : Key Vault Certificate Friendly Name, cert01"
  echo "-t : Azure Tenant ID"
  echo "
This script will take a PKCS#12 keystore file (p12/pfx) in binary format (EJBCA default format for a p12), convert 
it to PEM, and upload the keystore to an Azure Key Vault.
 Before running this script you need the following:

 1. 'jq' installed on the machine using this script, to parse/format JSON

 2. A Key Vault instance in Microsoft Azure that is ready to use with proper permissions setup for the client ID to access and import

 3. A p12 file to upload to Key Vault

keyVault_ImportCert.sh -t testcompany.com -i 2f5gh8ty3-29ee-41cf-e34t-8gb70195757 -p 47829_.MRUEYweryseri32d_ -n ejbca-vault -s test1 -f /var/tmp/test1.p12 -c p12password
"
exit
}

while getopts "n:p:i:f:t:c:s:aexh" optname ; do
  case $optname in
    n )
      VAULT_NAME=$OPTARG ;;
    p )
      VAULT_PASSWORD=$OPTARG ;;
    i )
      CLIENT_ID=$OPTARG ;;
    f )
      CERTIFICATE_FILE=$OPTARG ;;
    c )
      CERTIFICATE_FILE_PASSWORD=$OPTARG ;;
    e ) 
      EXPORT_CERTIFICATE=$OPTARG ;;
    a )
      VAULT_API_VERSION=$OPTARG ;;
    t )
      AZURE_TENANT_ID=$OPTARG ;;
    s )
      VAULT_CERT_NAME=$OPTARG ;;
    x )
      set -x ;;
    h )
      help ; exit 0 ;;  
    ? )
      echo "Unknown option $OPTARG." ; help ; exit 1 ;;
    : )
      echo "No argument value for option $OPTARG." ; help ; exit 1 ;;
    * )
      echo "Unknown error while processing options." ;;
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$VAULT_NAME" ] || [ -z "$VAULT_PASSWORD" ] || [ -z "$CLIENT_ID" ] || [ -z "$CERTIFICATE_FILE" ] || [ -z "$AZURE_TENANT_ID" ] ;
then
   echo "Some or all of the parameters are empty";
   help
fi

# Login to Azure and get a token to use Key Vault
JSONRESP=$(curl -sd "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$VAULT_PASSWORD&resource=https://vault.azure.net" https://login.microsoftonline.com/$AZURE_TENANT_ID/oauth2/token)
TOKEN=$(echo $JSONRESP | jq .access_token -r)

# Check if token is not null, if null exit
if [ "$TOKEN" == "null" ] ; then
    echo "Unable to get token:"
    echo $JSON
    exit
fi 

# Base64 encode the p12 file
if [ -f $CERTIFICATE_FILE ] ; then
    cert=$(base64 -i $CERTIFICATE_FILE)
else 
    echo "Can't access p12 file: $CERTIFICATE_FILE"
    exit
fi

# Create JSON template to upload the certiicate to Key Vault. Example from MS Docs:
#{
#  "value": "MIIJOwIBAzCCCPcGCSqGSIb3DQEHAaCCCOgEggjkMIII4DCCBgkGCSqGSIb3DQEHAaCCBfoEggX2MIIF8jCCBe4GCyqGSIb3DQEMCgECoIIE/jCCBPowHAYKKoZIhvcNAQwBAzAOBAj15YH9pOE58AICB9AEggTYLrI+SAru2dBZRQRlJY7XQ3LeLkah2FcRR3dATDshZ2h0IA2oBrkQIdsLyAAWZ32qYR1qkWxLHn9AqXgu27AEbOk35+pITZaiy63YYBkkpR+pDdngZt19Z0PWrGwHEq5z6BHS2GLyyN8SSOCbdzCz7blj3+7IZYoMj4WOPgOm/tQ6U44SFWek46QwN2zeA4i97v7ftNNns27ms52jqfhOvTA9c/wyfZKAY4aKJfYYUmycKjnnRl012ldS2lOkASFt+lu4QCa72IY6ePtRudPCvmzRv2pkLYS6z3cI7omT8nHP3DymNOqLbFqr5O2M1ZYaLC63Q3xt3eVvbcPh3N08D1hHkhz/KDTvkRAQpvrW8ISKmgDdmzN55Pe55xHfSWGB7gPw8sZea57IxFzWHTK2yvTslooWoosmGxanYY2IG/no3EbPOWDKjPZ4ilYJe5JJ2immlxPz+2e2EOCKpDI+7fzQcRz3PTd3BK+budZ8aXX8aW/lOgKS8WmxZoKnOJBNWeTNWQFugmktXfdPHAdxMhjUXqeGQd8wTvZ4EzQNNafovwkI7IV/ZYoa++RGofVR3ZbRSiBNF6TDj/qXFt0wN/CQnsGAmQAGNiN+D4mY7i25dtTu/Jc7OxLdhAUFpHyJpyrYWLfvOiS5WYBeEDHkiPUa/8eZSPA3MXWZR1RiuDvuNqMjct1SSwdXADTtF68l/US1ksU657+XSC+6ly1A/upz+X71+C4Ho6W0751j5ZMT6xKjGh5pee7MVuduxIzXjWIy3YSd0fIT3U0A5NLEvJ9rfkx6JiHjRLx6V1tqsrtT6BsGtmCQR1UCJPLqsKVDvAINx3cPA/CGqr5OX2BGZlAihGmN6n7gv8w4O0k0LPTAe5YefgXN3m9pE867N31GtHVZaJ/UVgDNYS2jused4rw76ZWN41akx2QN0JSeMJqHXqVz6AKfz8ICS/dFnEGyBNpXiMRxrY/QPKi/wONwqsbDxRW7vZRVKs78pBkE0ksaShlZk5GkeayDWC/7Hi/NqUFtIloK9XB3paLxo1DGu5qqaF34jZdktzkXp0uZqpp+FfKZaiovMjt8F7yHCPk+LYpRsU2Cyc9DVoDA6rIgf+uEP4jppgehsxyT0lJHax2t869R2jYdsXwYUXjgwHIV0voj7bJYPGFlFjXOp6ZW86scsHM5xfsGQoK2Fp838VT34SHE1ZXU/puM7rviREHYW72pfpgGZUILQMohuTPnd8tFtAkbrmjLDo+k9xx7HUvgoFTiNNWuq/cRjr70FKNguMMTIrid+HwfmbRoaxENWdLcOTNeascER2a+37UQolKD5ksrPJG6RdNA7O2pzp3micDYRs/+s28cCIxO//J/d4nsgHp6RTuCu4+Jm9k0YTw2Xg75b2cWKrxGnDUgyIlvNPaZTB5QbMid4x44/lE0LLi9kcPQhRgrK07OnnrMgZvVGjt1CLGhKUv7KFc3xV1r1rwKkosxnoG99oCoTQtregcX5rIMjHgkc1IdflGJkZzaWMkYVFOJ4Weynz008i4ddkske5vabZs37Lb8iggUYNBYZyGzalruBgnQyK4fz38Fae4nWYjyildVfgyo/fCePR2ovOfphx9OQJi+M9BoFmPrAg+8ARDZ+R+5yzYuEc9ZoVX7nkp7LTGB3DANBgkrBgEEAYI3EQIxADATBgkqhkiG9w0BCRUxBgQEAQAAADBXBgkqhkiG9w0BCRQxSh5IAGEAOAAwAGQAZgBmADgANgAtAGUAOQA2AGUALQA0ADIAMgA0AC0AYQBhADEAMQAtAGIAZAAxADkANABkADUAYQA2AGIANwA3MF0GCSsGAQQBgjcRATFQHk4ATQBpAGMAcgBvAHMAbwBmAHQAIABTAHQAcgBvAG4AZwAgAEMAcgB5AHAAdABvAGcAcgBhAHAAaABpAGMAIABQAHIAbwB2AGkAZABlAHIwggLPBgkqhkiG9w0BBwagggLAMIICvAIBADCCArUGCSqGSIb3DQEHATAcBgoqhkiG9w0BDAEGMA4ECNX+VL2MxzzWAgIH0ICCAojmRBO+CPfVNUO0s+BVuwhOzikAGNBmQHNChmJ/pyzPbMUbx7tO63eIVSc67iERda2WCEmVwPigaVQkPaumsfp8+L6iV/BMf5RKlyRXcwh0vUdu2Qa7qadD+gFQ2kngf4Dk6vYo2/2HxayuIf6jpwe8vql4ca3ZtWXfuRix2fwgltM0bMz1g59d7x/glTfNqxNlsty0A/rWrPJjNbOPRU2XykLuc3AtlTtYsQ32Zsmu67A7UNBw6tVtkEXlFDqhavEhUEO3dvYqMY+QLxzpZhA0q44ZZ9/ex0X6QAFNK5wuWxCbupHWsgxRwKftrxyszMHsAvNoNcTlqcctee+ecNwTJQa1/MDbnhO6/qHA7cfG1qYDq8Th635vGNMW1w3sVS7l0uEvdayAsBHWTcOC2tlMa5bfHrhY8OEIqj5bN5H9RdFy8G/W239tjDu1OYjBDydiBqzBn8HG1DSj1Pjc0kd/82d4ZU0308KFTC3yGcRad0GnEH0Oi3iEJ9HbriUbfVMbXNHOF+MktWiDVqzndGMKmuJSdfTBKvGFvejAWVO5E4mgLvoaMmbchc3BO7sLeraHnJN5hvMBaLcQI38N86mUfTR8AP6AJ9c2k514KaDLclm4z6J8dMz60nUeo5D3YD09G6BavFHxSvJ8MF0Lu5zOFzEePDRFm9mH8W0N/sFlIaYfD/GWU/w44mQucjaBk95YtqOGRIj58tGDWr8iUdHwaYKGqU24zGeRae9DhFXPzZshV1ZGsBQFRaoYkyLAwdJWIXTi+c37YaC8FRSEnnNmS79Dou1Kc3BvK4EYKAD2KxjtUebrV174gD0Q+9YuJ0GXOTspBvCFd5VT2Rw5zDNrA/J3F5fMCk4wOzAfMAcGBSsOAwIaBBSxgh2xyF+88V4vAffBmZXv8Txt4AQU4O/NX4MjxSodbE7ApNAMIvrtREwCAgfQ",
#  "pwd": "123",
#  "policy": {
#    "key_props": {
#      "exportable": true,
#      "kty": "RSA",
#      "key_size": 2048,
#      "reuse_key": false
#    },
#    "secret_props": {
#      "contentType": "application/x-pkcs12"
#    }
#  }
#}
template='{"value":$cert, "pwd":$pwd, "policy":{ "key_props":{ "exportable":$exportable }, "secret_props":{ "contentType": "application/x-pkcs12" } } }'

#Format the template with variables using jq
json_payload=$(jq -n \
    --arg cert "$cert" \
    --arg pwd "$CERTIFICATE_FILE_PASSWORD" \
    --arg exportable "$EXPORT_CERTIFICATE" \
    "$template")

# Post the certificate for import to Key Vault    
curl -X POST -s \
    -H 'Content-Type: application/json' \
    -H 'Accept:application/json' \
    -H "Authorization: Bearer $TOKEN" \
    --data "$json_payload" \
    "https://$VAULT_NAME.vault.azure.net/certificates/$VAULT_CERT_NAME/import?api-version=$VAULT_API_VERSION" \
    | jq .
