#!/bin/bash
set -e

echo "Host: ${HOST_URL} http://${IP_ADDRESS}/world"
echo $(curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}/world)
