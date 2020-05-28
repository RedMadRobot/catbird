#!/bin/sh

# work directory
cd "$(dirname "$0")"

# Set file for logs
exec > server.log 2>&1

# Run the mock server and send it to background (using &)
./catbird serve bind 0.0.0.0:8080 &

# Record the PID of the last background process (using $!)
echo $! > server.pid
