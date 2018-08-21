#!/bin/bash
set -e

# Install Istio
curl -L https://raw.githubusercontent.com/knative/serving/v0.1.1/third_party/istio-0.8.0/istio.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply -f -

# Label the default namespace with istio-injection=enabled
kubectl label namespace default istio-injection=enabled

# Wait for Istio to be ready
echo "Waiting for Istio to be ready ..."
for i in {1..30}; do # Timeout after 5 minutes
  if kubectl get pods --namespace=istio-system -listio=pilot|grep Running ; then
    break
  fi
  sleep 10
done

kubectl get pods --namespace=istio-system

# Install Knative
curl -L https://github.com/knative/serving/releases/download/v0.1.1/release-lite.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply -f -

# Wait for Knative to be ready
echo "Waiting for Knative to be ready ..."
for i in {1..60}; do # Timeout after 5 minutes
  if kubectl get pods --namespace=knative-serving -lapp=activator|grep Running && \
  	 kubectl get pods --namespace=knative-serving -lapp=controller|grep Running && \
  	 kubectl get pods --namespace=knative-serving -lapp=webhook|grep Running ; then
    break
  fi
  sleep 5
done

kubectl get pods --namespace=knative-serving

echo $(minikube ip):$(kubectl get svc knative-ingressgateway -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
