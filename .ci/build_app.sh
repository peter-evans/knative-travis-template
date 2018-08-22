#!/bin/bash
set -e

docker build -t helloworld-go .

kubectl apply -f service.yml

kubectl get pods --show-labels

# Wait for helloworld-go to be ready
echo "Waiting for helloworld-go to be ready ..."
for i in {1..5}; do # Timeout after 5 minutes
  #kubectl get pods --all-namespaces --show-labels
  kubectl get services.serving.knative.dev helloworld-go -o json
  kubectl get route
  kubectl get revisions
  #if kubectl get pods --namespace=istio-system -listio=pilot|grep Running ; then
  #  break
  #fi
  sleep 2
done

export IP_ADDRESS=$(kubectl get node -o 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc knative-ingressgateway -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
export HOST_URL=$(kubectl get services.serving.knative.dev helloworld-go -o jsonpath='{.status.domain}')

echo $IP_ADDRESS
echo $HOST_URL
