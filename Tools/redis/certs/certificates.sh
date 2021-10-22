
#!/usr/bin/env bash

# Set the TLD domain we want to use
BASE_DOMAIN="localhost"

# Days for the cert to live
#DAYS=1095

# A blank passphrase
#PASSPHRASE=""

# Generated configuration file
CONFIG_FILE="config.txt"

#[req]
#distinguished_name = req_distinguished_name
#req_extensions = v3_req
#default_keyfile = example-client.key
#prompt = no
#[req_distinguished_name]
#C = Your Country Name
#ST = Your State
#L = Your Location
#O = Your Org Name
#OU = Your Org Unit
#CN = Host IP    
#[v3_req]
#keyUsage = keyEncipherment, dataEncipherment
#extendedKeyUsage = serverAuth
#subjectAltName = @alt_names
#[alt_names]
#DNS.1 = Hostname of your 1st server
#DNS.2 = Hostname of your 2nd  server
#DNS.3 = Hostname of your 3rd server
#DNS.4 = Hostname of your 4th server
#DNS.5 = Hostname of your 5th server
#DNS.6 = Hostname of your 6th server

cat > $CONFIG_FILE <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = v3_req
distinguished_name = dn

[dn]
C = ES
ST = Barcelona 
L = Barcelona 
O = Monitoring 
OU = IT
emailAddress = me@email.com 
CN = $BASE_DOMAIN

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $BASE_DOMAIN
EOF

# The file name can be anything
FILE_NAME="redis"

# Remove previous keys
echo "Removing existing certs like $FILE_NAME.*"
chmod 770 $FILE_NAME.*
rm $FILE_NAME.*

echo "Generating certs for $BASE_DOMAIN"

# Generate 2 certificates:
# 1. A certificate Key Pair for the server
#   + san.crt (subject alternative certificate)
#   + private.Key
# 2. A root CA certificate
#   + rootca.crt

echo "Generate a rootCA private key"
openssl genrsa -out ca-$FILE_NAME-private-key.pem 2048
echo "Generate a rootCA public key"
openssl rsa -in ca-$FILE_NAME-private-key.pem -pubout -out ca-$FILE_NAME-public-key.pem
echo "Generate a rootCA certificate"
openssl req -new -x509 -key ca-$FILE_NAME-private-key.pem -out CA-$FILE_NAME-cert.pem -days 1000 -config "$CONFIG_FILE"

echo "Generate a san configuration"
openssl req -out $FILE_NAME-sslcert.csr -newkey rsa:2048 -nodes -keyout $FILE_NAME-private.key -config "$CONFIG_FILE"

echo "Generate SAN certificate"
openssl x509 -req -days 365 -in $FILE_NAME-sslcert.csr -CA CA-$FILE_NAME-cert.pem  -CAkey ca-$FILE_NAME-private-key.pem  -CAcreateserial -out $FILE_NAME-san.crt

# OPTIONAL - write an info to see the details of the generated crt
# Protect the key
#chmod 400 "$FILE_NAME.key"
