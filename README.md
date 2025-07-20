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


## Documentation

* [GitOps](./docs/gitops.md)
* [Kind](./docs/kind.md)
* [Development](./docs/development.md)