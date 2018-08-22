#!/bin/bash
set -e

APP_NAME="helloworld-go"

docker run -d -p 5000:5000 --restart=always --name registry registry:2

docker build -t helloworld-go .
docker tag helloworld-go localhost:5000/helloworld-go
docker push localhost:5000/helloworld-go

kubectl apply -f service.yml

# Wait for helloworld-go to be ready
echo "Waiting for helloworld-go to be ready ..."
JSONPATH="{range .status.conditions[?(@.type=='Ready')]}{@.type}={@.status};{end}"
for i in {1..15}; do # Timeout after 5 minutes
  if kubectl get services.serving.knative.dev helloworld-go -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; then
    break
  fi
  kubectl get services.serving.knative.dev helloworld-go -o json
  sleep 2
done

export IP_ADDRESS=$(kubectl get node -o 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc knative-ingressgateway -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
export HOST_URL=$(kubectl get services.serving.knative.dev helloworld-go -o jsonpath='{.status.domain}')

echo $IP_ADDRESS
echo $HOST_URL
