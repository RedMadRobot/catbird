#!/bin/sh
set -e

CONFIG_FILE=cert.config
if ! test -f "$CONFIG_FILE"; then
    echo "$CONFIG_FILE file doesn't exists. Add cert.config file with certificate configuration."
    exit 1
fi

echo "Creating new certificate from cert.config"

echo "Enter password for new certificate."
read -s -p  "Password: " password

# Generate RSA Key
openssl genrsa -aes256 -passout pass:"$password" -out key.pem 2048

# Generate the self-signed certificate and private key
openssl req -x509 -new -nodes -passin pass:"$password" -config cert.config -key key.pem -sha256 -extensions v3_ca -days 365 -out root-ca.pem

# Cleanup
rm key.pem

echo "Certificate created: root_ca.pem"
