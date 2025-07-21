# Local Development Guide

This guide shows how to build, run, and test the application locally — both with Docker and Helm.

## Pull and Run with Docker

### Pull the container

```bash
# Pull the latest 
➜  ~ docker pull lbohdan93/go_webapp:latest
latest: Pulling from lbohdan93/go_webapp
Status: Downloaded newer image for lbohdan93/go_webapp:latest
docker.io/lbohdan93/go_webapp:latest
# Or specify tag
➜  ~ docker pull lbohdan93/go_webapp:0.4.1 
0.4.1: Pulling from lbohdan93/go_webapp
Digest: sha256:912461afef49c364d30a53f94032229c06c9d36f7a14d9c679be1ffa8c96d239
Status: Downloaded newer image for lbohdan93/go_webapp:0.4.1
docker.io/lbohdan93/go_webapp:0.4.1
# Check images
➜  ~ docker image ls
REPOSITORY            TAG       IMAGE ID       CREATED        SIZE
lbohdan93/go_webapp   0.4.1     129b94382faf   22 hours ago   12.5MB
lbohdan93/go_webapp   latest    129b94382faf   22 hours ago   12.5MB
```

Alternatively image can be built from `Dockerfile`:
```bash
# Navigate to the root dir of repo:
➜  homework git:(main) ls
charts  Dockerfile  docs  fluxcd  init_kind.sh  kind-cfg.yaml  README.md  web-app
# Build from Dockerfile
➜  homework git:(main) docker build -t lbohdan93/go_webapp:0.5.0-bugfix .
[+] Building 1.1s (16/16)                                                                                                                                      x
............................................................
............................................................
............................................................
 => => naming to docker.io/lbohdan93/go_webapp:0.5.0-bugfix
➜  homework git:(main) docker image ls
REPOSITORY            TAG            IMAGE ID       CREATED        SIZE
lbohdan93/go_webapp   0.4.1          129b94382faf   22 hours ago   12.5MB
lbohdan93/go_webapp   0.5.0-bugfix   129b94382faf   22 hours ago   12.5MB
lbohdan93/go_webapp   latest         129b94382faf   22 hours ago   12.5MB
```

### Run the container

```bash
➜  ~ docker run -p 8080:8080 lbohdan93/go_webapp:latest
2025/07/21 08:55:48 main.go:23: listening on :8080
2025/07/21 08:56:11 main.go:40: 172.17.0.1:43760 GET /
2025/07/21 08:56:12 main.go:40: 172.17.0.1:43760 GET /favicon.ico
```

- `--p 8080:8080` maps local port to container port.

App should now be accessible at http://localhost:8080, or `curl` can be used:

```bash
➜  ~ curl http://localhost:8080
System environment variables:
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  HOSTNAME=35bc2e35d972
  HOME=/home/gopher
```

Above instructions run container in foreground mode(logs printed to stdout)
To stop the container - use `CTRL+C`

For running it in detached mode `-d`(runs in background):
```bash
➜  ~ docker run -d -p 8080:8080 lbohdan93/go_webapp:latest
3a87c7afef47d7d067289277c7ac87abc7e3719a7b0bf946bac4a278c1e1bb3f
# To find container id
➜  ~ docker ps 
CONTAINER ID   IMAGE                        COMMAND                  CREATED              STATUS              PORTS                                         NAMES
3a87c7afef47   lbohdan93/go_webapp:latest   "/homework/web-app"      About a minute ago   Up About a minute   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp   crazy_panini
# To check logs use first 4 chars of the container ID(or full ID)
➜  ~ docker logs 3a87
2025/07/21 09:04:12 main.go:23: listening on :8080
```

To stop the container run:

```bash
➜  ~ docker stop 3a87
3a87
➜  ~ docker ps -l            
CONTAINER ID   IMAGE                        COMMAND               CREATED         STATUS                      PORTS     NAMES
3a87c7afef47   lbohdan93/go_webapp:latest   "/homework/web-app"   3 minutes ago   Exited (2) 46 seconds ago             crazy_panini
```

### Cleanup docker image

```bash
# List images
➜  ~ docker image ls
REPOSITORY            TAG            IMAGE ID       CREATED        SIZE
lbohdan93/go_webapp   0.4.1          129b94382faf   22 hours ago   12.5MB
lbohdan93/go_webapp   0.5.0-bugfix   129b94382faf   22 hours ago   12.5MB
lbohdan93/go_webapp   latest         129b94382faf   22 hours ago   12.5MB
# Delete images using IMAGE ID
➜  ~ docker rmi 129b94382faf
# If it throws an error use --force flag
➜  ~ docker rmi 129b94382faf --force
Untagged: lbohdan93/go_webapp:0.4.1
Untagged: lbohdan93/go_webapp:0.5.0-bugfix
Untagged: lbohdan93/go_webapp:latest
Untagged: lbohdan93/go_webapp@sha256:912461afef49c364d30a53f94032229c06c9d36f7a14d9c679be1ffa8c96d239
Deleted: sha256:129b94382faf94b99ac55274dcbd5ca630b4270faeb30ec8768156a57cfd3d9a
```

## Deploy Locally with Helm

For this step k8s cluster is needed. For how to set up kubernetes kind cluster see [Kind](kind.md).

### From Helm chart directory

This installs the chart with default `values`:

```bash
➜  internal-service git:(main) ✗ ls
Chart.yaml  templates  values.schema.json  values.yaml
➜  internal-service git:(main) ✗ helm install internal-service .
NAME: internal-service
LAST DEPLOYED: Mon Jul 21 11:20:55 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
```

Or install from helm repo:

```bash
# Add repo
➜  ~ helm repo add homework-repo https://Singullaritty.github.io/homework/
"homework-repo" has been added to your repositories
➜  internal-service git:(main) ✗ helm install internal-service homework-repo/internal-service
NAME: internal-service
LAST DEPLOYED: Mon Jul 21 11:23:50 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
```

To override the values from CLI:

```bash
➜  internal-service git:(main) ✗ helm install internal-service . --set prod=false 
```

Or with values file `values.yaml`:

```yaml
replicaCount: 5
prod: false
autoscaling:
  enabled: false
```

```bash
➜  internal-service git:(main) ✗ helm install internal-service . -f values.yaml
```

Verify installation:

```bash
➜  ~ helm list 
NAME                    NAMESPACE       REVISION        UPDATED                                         STATUS          CHART                   APP VERSION
internal-service        default         1               2025-07-21 11:23:50.883525488 +0200 CEST        deployed        internal-service-0.4.1  0.4.1
```bash
~ kubectl get all -n default
NAME                                    READY   STATUS    RESTARTS   AGE
pod/internal-service-7cbfdd99f7-88bjt   1/1     Running   0          3m41s
pod/internal-service-7cbfdd99f7-dfhc4   1/1     Running   0          3m56s
pod/internal-service-7cbfdd99f7-nmv6m   1/1     Running   0          3m41s

NAME                       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/internal-service   ClusterIP   10.96.10.171   <none>        8080/TCP   3m56s
service/kubernetes         ClusterIP   10.96.0.1      <none>        443/TCP    51m

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/internal-service   3/3     3            3           3m56s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/internal-service-7cbfdd99f7   3         3         3       3m56s

NAME                                                   REFERENCE                     TARGETS                       MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/internal-service   Deployment/internal-service   cpu: 1%/75%, memory: 1%/80%   3         10        3          3m56s
```

Check if `internal-service` app is working:

```bash
➜  ~ kubectl port-forward svc/internal-service 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
➜  ~ curl http://localhost:8080
System environment variables:
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  HOSTNAME=internal-service-7cbfdd99f7-dfhc4
  PROD=false
  ..........................................
  # some k8s sepcific vars
  ..........................................
  KUBERNETES_PORT_443_TCP_PROTO=tcp
  HOME=/home/gopher
```

Alternatively `NodePort` as service type can be used. `NodePort` service in Kubernetes is a service that 
is used to expose the application to the internet, primarily used for development and testing purposes.

```bash
➜  ~ helm install internal-service homework-repo/internal-service --set service.type=NodePort
NAME: internal-service
LAST DEPLOYED: Mon Jul 21 11:35:50 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services internal-service)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
➜  ~ curl http://$NODE_IP:$NODE_PORT
System environment variables:
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  HOSTNAME=internal-service-556b5c898b-9hck7
  PROD=true
  ..........................................
  # some k8s sepcific vars
  ..........................................
  KUBERNETES_PORT_443_TCP_PROTO=tcp
  HOME=/home/gopher
```

Above instructions deploy helm chart to the default namespace, to specify namespace use `--namespace`.
If namespace needs to be created use `--create-namespace` flag.

To upgrade release with changes:

```bash
➜  ~ helm upgrade internal-service . -f values.yaml
```

Uninstall the release:

```bash
➜  ~ helm uninstall internal-service
```