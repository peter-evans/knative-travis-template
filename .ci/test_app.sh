#!/bin/bash
set -e

curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}/world
