#!/bin/sh
set -e

CERT_FILE=root-ca.pem
if ! test -f "$CERT_FILE"; then
    echo "$CERT_FILE file doesn't exists. Generate it using generate-certificate.sh."
    exit 1
fi

# Add certificate to macOS Keychain
echo "You will be promted to authenticate to mark certificate as trusted"

# Get path to the local keychain and trim whitespaces and quotation marks symbol
LOGIN_KEYCHAIN="$(security login-keychain | sed 's/[[:space:]]*"//g')"
security add-trusted-cert -k $LOGIN_KEYCHAIN root-ca.pem

echo "Certificate has been successfully added to the macOS Keychain"
