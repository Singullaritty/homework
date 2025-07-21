# Setting up a Local Kubernetes Cluster with kind

This guide shows how to setup a local Kubernetes cluster using [kind](https://kind.sigs.k8s.io/).

## Files

- `init_kind.sh` – Bash script to automatically create the cluster
- `kind-cfg.yaml` – kind cluster configuration file

## Prerequisites

Make sure the following tools installed:

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

## Create the Cluster with bash script

It creates a k8s cluster with 4 nodes(1 master & 3 workers).
Execute the script to create the cluster:

```bash
➜ ~ ./init_kind.sh 
Creating cluster "kind-playground" ...
 ✓ Ensuring node image (kindest/node:v1.33.1) 🖼
 ✓ Preparing nodes 📦 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-kind-playground"
You can now use your cluster with:

kubectl cluster-info --context kind-kind-playground

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
Waiting for all nodes to be in ready state...
All nodes are Ready.
Installing metrics-server in order to make deployment autoscaler work...
```

Verify installation:

```bash
➜  ~ kind get clusters
kind-playground
➜  ~ kubectl cluster-info --context kind-kind-playground
Kubernetes control plane is running at https://127.0.0.1:34485
CoreDNS is running at https://127.0.0.1:34485/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
➜  ~ kubectl get nodes
NAME                            STATUS   ROLES           AGE     VERSION
kind-playground-control-plane   Ready    control-plane   4m33s   v1.33.1
kind-playground-worker          Ready    <none>          4m23s   v1.33.1
kind-playground-worker2         Ready    <none>          4m23s   v1.33.1
kind-playground-worker3         Ready    <none>          4m23s   v1.33.1
```

## Create the Cluster Manually

Separate config file can be used or modify `kind-cfg.yaml` to meet the needs:

```yaml 
# 4 node (3 workers) config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```

To create the cluster manually, run:
```bash
kind create cluster --name your-cluster-name --config your-config-file.yaml
```

- `--name` sets the cluster name (e.g., `test-cluster`)
- `--config` points to custom configuration (number of worker/master nodes)

## Cleanup 

To remove the cluster:
```bash
# Get cluster name
➜  ~ kind get clusters
kind-playground
# Delete the cluster
➜  ~ kind delete cluster --name  kind-playground
Deleting cluster "kind-playground" ...
Deleted nodes: ["kind-playground-worker2" "kind-playground-worker" "kind-playground-control-plane" "kind-playground-worker3"]
```