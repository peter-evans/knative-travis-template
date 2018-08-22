#!/bin/bash
set -e

echo $(curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}/world)
