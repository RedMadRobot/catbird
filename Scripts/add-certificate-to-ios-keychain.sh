#!/bin/sh
set -e

CERT_FILE=root-ca.pem
if ! test -f "$CERT_FILE"; then
    echo "$CERT_FILE file doesn't exists. Generate it using generate-self-signed-certificate.sh"
    exit 1
fi

# Find booted iOS Simulator
while true; do
  export UDID=$(xcrun simctl list devices | grep "(Booted)" | grep -E -o -i "([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})")  
  if [ -z "$UDID" ]
  then
    echo "Please launch an iOS Simulator in which you would like to install certificate and press any key"
    read input
  else
    break
  fi
done

# Add certificate to iOS Simulator
echo "Adding certificate to iOS Sumulator..."
xcrun simctl keychain booted add-root-cert root-ca.pem

# Restart booted iOS Simulator
echo "Restarning iOS Sumulator..."
xcrun simctl shutdown $UDID
xcrun simctl boot $UDID

echo "Certificate has been successfully added to the iOS Simulator Keychain"
