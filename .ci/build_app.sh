#!/bin/bash
set -e

export APP_NAME="helloworld-go"

docker build -t helloworld-go:v1 .

kubectl apply -f service.yml

# Wait for helloworld-go to be ready
echo "Waiting for helloworld-go to be ready ..."
for i in {1..15}; do # Timeout after 5 minutes
  if kubectl get services.serving.knative.dev helloworld-go -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; then
    break
  fi
  kubectl get services.serving.knative.dev helloworld-go -o jsonpath="$JSONPATH"
  sleep 2
done

export IP_ADDRESS=$(kubectl get node -o 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc knative-ingressgateway -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
export HOST_URL=$(kubectl get services.serving.knative.dev helloworld-go -o jsonpath='{.status.domain}')

echo $IP_ADDRESS
echo $HOST_URL
