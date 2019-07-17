#!/bin/sh
set -e

# work directory
cd "$(dirname "$0")"

# When finished, kill the mock server (from the same shell)
kill $(< server.pid)

# Remove PID file
rm server.pid

# Write log
echo "Server stopped." >> server.log 
