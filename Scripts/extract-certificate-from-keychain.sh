#!/bin/sh
set -e

# Get an existing Catbird certificate
security find-certificate -c Catbird -p > root-ca.pem
