# internal-service

**internal-service** is a web-based application written in [Golang](https://go.dev/), listening on port **8080** by default.

## Repo structure
```plaintext
.github         # Github actions workflow
charts/         # Helm chart definition for internal-service app
docs/           # Documentation files
fluxcd/         # GitOps setup with FluxCD
web-app/        # Source code for internal-service
Dockerfile      # Build instructions to build an internal-service image
init_kind.sh    # Bash script for preparing kind cluster
kind-cfg.yaml   # Config file for kind cluster
```

## 📋 Requirements

Before getting started, make sure you have the following tools installed on your workstation:

### 1. [kind (Kubernetes IN Docker)](https://kind.sigs.k8s.io/)
Kind run local Kubernetes clusters using Docker containers. [Kind installation guide](https://kind.sigs.k8s.io/docs/user/quick-start/)

### 2. [Helm](https://helm.sh/)
Helm is the package manager for Kubernetes.

Helm installation guide: [Helm installation guide](https://helm.sh/docs/intro/install/)

### 3. [kubectl](https://kubernetes.io/docs/tasks/tools/)
kubectl is the command-line tool for interacting with Kubernetes cluster.

Install guide: [Kubernetes installation guide](https://kubernetes.io/docs/tasks/tools/)

### 4. [FluxCD CLI](https://fluxcd.io/)
FluxCD is an open-source GitOps continuous delivery (CD) tool designed for Kubernetes.

Install guide: [FluxCD cli installation guide](https://fluxcd.io/flux/installation/#install-the-flux-cli)

### 5. [Docker](https://www.docker.com/)
Docker is an open source platform that enables developers to build, deploy, run, update and manage containerized applications.

Install guide: [Docker installation guide](https://docs.docker.com/get-docker/)

## Documentation

* [GitOps](./docs/gitops.md)
* [Kind](./docs/kind.md)
* [Development](./docs/development.md)
