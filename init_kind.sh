#!/usr/bin/env bash

KIND_CLUSTER_NAME="kind-playground"
KIND_CLUSTER_CFG="kind-cfg.yaml"
TIMEOUT=60
INTERVAL=5
ELAPSED=0

# Check if kind is installed
if ! [ -x "$(command -v kind)" ]; then
  echo 'Error: kind binary is not installed.' >&2
  exit 1
fi

# Check if kubectl is installed
if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  exit 1
fi

# Generate config for kind cluster
cat > $KIND_CLUSTER_CFG <<EOF
# 4 node (3 workers) config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

# Deploy cluster with kind
kind create cluster --name $KIND_CLUSTER_NAME --config $KIND_CLUSTER_CFG

# Waiting for nodes to be ready & installing metric-server for hpa
echo "Waiting for all nodes to be in ready state..."
while true; do
  NOT_READY=$(kubectl get nodes --no-headers | grep -v " Ready" || true)

  if [[ -z "$NOT_READY" ]]; then
    echo "All nodes are Ready."
    echo "Installing metrics-server in order to make deployment autoscaler work..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 1> /dev/null
    kubectl patch deployment metrics-server -n kube-system \
      --type='json' \
      -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]' 1> /dev/null
    break
  fi

  if (( ELAPSED >= TIMEOUT )); then
    echo "Some nodes are not Ready:"
    kubectl get nodes -o wide
    exit 1
  fi

  sleep $INTERVAL
  ((ELAPSED += INTERVAL))
done
