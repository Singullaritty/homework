# GitOps with FluxCD

This guide explains GitOps with FluxCD, how to set it up per environment (e.g., dev/prod), verify setup, and modify deployments.

## What is GitOps?

**GitOps** is a declarative approach to managing infrastructure and application configuration using Git as the single source of truth. 

With **FluxCD**, every change made to Git repository is automatically reconciled with Kubernetes cluster.

Benefits of GitOps:
- Version-controlled infrastructure and app configs.
- Automated, auditable, and reproducible deployments.

## FluxCD general structure

The flux repository contains the following top directories:

- **base** dir contains the common configuration that applies to all environments.
- **overlays** dir contains Helm releases with a custom configuration per cluster.
- **clusters** dir contains the Flux configuration per cluster.

```
fluxcd
├── base
│   └── internal-service
├── clusters
│   ├── dev
│   └── prod
└── overlays
    ├── dev
    └── prod
```

The apps configuration is structured into:

- **fluxcd/base/** dir contains namespaces and Helm release definitions.
- **fluxcd/overlays/prod/** dir contains the production Helm release values.
- **fluxcd/overlays/dev/** dir contains the dev environment values.

```
base
└── internal-service
    ├── helmrelease.yaml
    ├── helmrepo.yaml
    ├── kustomization.yaml
    └── namespace.yaml
overlays
├── dev
│   ├── helm-values.yaml
│   └── kustomization.yaml
└── prod
    ├── helm-values.yaml
    └── kustomization.yaml
```

In **fluxcd/base/internal-service/** a Flux `HelmRelease` defines common values for both clusters:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: internal-service
  namespace: platform
spec:
  interval: 1m0s
  install:
    disableWait: true
  releaseName: internal-service
  chart:
    spec:
      chart: internal-service
      sourceRef:
        kind: HelmRepository
        name: internal-service-repo
        namespace: platform
  timeout: 30m0s
  ```

In **fluxcd/overlays/dev/** there is a `Kustomize` patch with the dev environment specific values:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: internal-service 
  namespace: platform # target namespace
spec:
  chart:
    spec:
      version: 0.4.0
  values:
    prod: false
    podLabels:
      app: internal-service-dev
```

In **fluxcd/clusters/dev/** dir there are Flux Kustomization definitions, for example:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: bootstrap
  namespace: flux-system
spec:
  interval: 10m0s
  sourceRef:
    kind: GitRepository
    name: homework
  path: ./fluxcd/overlays/dev
  prune: true
  wait: true
  timeout: 5m0s
```

## ️FluxCD Installation per environment

### Install Fluxcd(if needed)
If fluxcd not installed on the cluster, install it with helm:

```bash
➜  ~ helm repo add fluxcd https://fluxcd-community.github.io/helm-charts
➜  ~ helm upgrade -i flux fluxcd/flux2 --namespace flux-system --create-namespace
Release "flux" does not exist. Installing it now.
NAME: flux
LAST DEPLOYED: Mon Jul 21 12:35:50 2025
NAMESPACE: flux-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Verify if all fluxcd related pods are up and running:

```bash
➜  ~ kubectl get pods -n flux-system 
NAME                                           READY   STATUS    RESTARTS   AGE
helm-controller-6644d7f656-q4znl               1/1     Running   0          3m23s
image-automation-controller-7889467889-dzn9x   1/1     Running   0          3m23s
image-reflector-controller-758c7758d7-rvzbg    1/1     Running   0          3m23s
kustomize-controller-6995878b8c-vztbd          1/1     Running   0          3m23s
notification-controller-6dcc9df6c6-gwc6g       1/1     Running   0          3m23s
source-controller-66f6549998-vnzw5             1/1     Running   0          3m23s
```

### Bootstrap flux for dev environment

First login to kubernetes dev cluster, or switch context with `kubectl config use-context`.
To deploy `internal-service` to a dev environment with `fluxcd` first apply `bootstrap` and then `gitrepo` resources:

```bash
➜  fluxcd git:(main) kubectl apply -f clusters/dev/bootstrap.yaml 
kustomization.kustomize.toolkit.fluxcd.io/bootstrap created
➜  fluxcd git:(main) kubectl apply -f clusters/dev/gitrepo.yaml  
gitrepository.source.toolkit.fluxcd.io/homework created
# Check if resources deployed properly
➜  fluxcd git:(main) flux get sources git homework 
NAME            REVISION                SUSPENDED       READY   MESSAGE                                           
homework        main@sha1:31a68076      False           True    stored artifact for revision 'main@sha1:31a68076'
➜  fluxcd git:(main) flux get kustomizations bootstrap 
NAME            REVISION                SUSPENDED       READY   MESSAGE                              
bootstrap       main@sha1:31a68076      False           True    Applied revision: main@sha1:31a68076
```

Once it's done, flux going to reconcile objects from the repository defined in `gitrepo.yaml` and path for objects in `bootstrap.yaml`. 
We can verify if our helm-release installed(by default it installs it in `platform` namespace as defined in helmrelease):

```bash
➜  fluxcd git:(main) flux get helmreleases --namespace platform
NAME                    REVISION        SUSPENDED       READY   MESSAGE                                                                                           
internal-service        0.4.0           False           True    Helm install succeeded for release platform/internal-service.v1 with chart internal-service@0.4.0
➜  fluxcd git:(main) kubectl get all -n platform
NAME                                   READY   STATUS    RESTARTS   AGE
pod/internal-service-757bc594b-2lwrc   1/1     Running   0          6m9s
pod/internal-service-757bc594b-5jwtj   1/1     Running   0          6m24s
pod/internal-service-757bc594b-wxpzg   1/1     Running   0          6m9s

NAME                       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/internal-service   ClusterIP   10.96.43.75   <none>        8080/TCP   6m24s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/internal-service   3/3     3            3           6m24s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/internal-service-757bc594b   3         3         3       6m24s

NAME                                                   REFERENCE                     TARGETS                       MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/internal-service   Deployment/internal-service   cpu: 1%/75%, memory: 1%/80%   3         10        3          6m24s
```

## Making Changes with Kustomize Overlays

1. Pull latest chages from `main` branch and create a feature branch for changes applied:

```bash
➜  homework git:(main) git pull origin main
From github.com:Singullaritty/homework
 * branch            main       -> FETCH_HEAD
Already up to date.
➜  homework git:(main) git switch -c feature/upgrade-helm-release
Switched to a new branch 'feature/upgrade-helm-release'
```

2. Navigate to `fluxcd/overlays/dev/` and modify a patch (e.g. helm-release.yaml for HelmRelease)

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: internal-service 
  namespace: platform
spec:
  chart:
    spec:
      version: 0.4.1 # update helm release version
  values:
    prod: false
    podLabels:
      app: internal-service-dev
```

3. Commit & push the changes:

```bash
➜  homework git:(feature/upgrade-helm-release) ✗ git status
On branch feature/upgrade-helm-release
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   fluxcd/overlays/dev/helm-values.yaml

no changes added to commit (use "git add" and/or "git commit -a")
➜  homework git:(feature/upgrade-helm-release) ✗ git add .
➜  homework git:(feature/upgrade-helm-release) ✗ git commit -m "Upgrade dev helm release"
[feature/upgrade-helm-release bd9abfb] Upgrade dev helm release
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  homework git:(feature/upgrade-helm-release) git push origin feature/upgrade-helm-release
Enumerating objects: 11, done.
Counting objects: 100% (11/11), done.
Delta compression using up to 20 threads
Compressing objects: 100% (6/6), done.
Writing objects: 100% (6/6), 521 bytes | 521.00 KiB/s, done.
Total 6 (delta 3), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
remote: 
remote: Create a pull request for 'feature/upgrade-helm-release' on GitHub by visiting:
remote:      https://github.com/Singullaritty/homework/pull/new/feature/upgrade-helm-release
remote: 
To github.com:Singullaritty/homework.git
 * [new branch]      feature/upgrade-helm-release -> feature/upgrade-helm-release
```

4. Create a pull request and wait for approvals - once done merge it to the main branch.

Once PR merged to the main branch, verify the changes from fluxcd, it will take some time
once fluxcd reconcile gitrepo and kustomization. If its needed use:

```bash
flux reconcile source git homework
flux reconcile kustomization bootstrap
```

to force fluxcd to sync changes from repository and apply them.

To verify if upgrade succeed:

```bash
➜  homework git:(main) flux get helmreleases -n platform
NAME                    REVISION        SUSPENDED       READY   MESSAGE                                                                                           
internal-service        0.4.1           False           True    Helm upgrade succeeded for release platform/internal-service.v2 with chart internal-service@0.4.1
➜  homework git:(main) helm list -n platform 
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
internal-service        platform        2               2025-07-21 11:05:55.775540126 +0000 UTC deployed        internal-service-0.4.1  0.4.1
```

## Cleanup

Delete resources: 

```bash
➜  homework git:(main) kubectl delete -f fluxcd/clusters/dev/gitrepo.yaml
gitrepository.source.toolkit.fluxcd.io "homework" deleted
➜  homework git:(main) kubectl delete -f fluxcd/clusters/dev/bootstrap.yaml 
kustomization.kustomize.toolkit.fluxcd.io "bootstrap" deleted
```

Uninstall fluxcd(if needed):

```bash
➜  homework git:(main) helm list -n flux-system 
NAME    NAMESPACE       REVISION        UPDATED                                         STATUS          CHART           APP VERSION
flux    flux-system     1               2025-07-21 12:35:50.697824348 +0200 CEST        deployed        flux2-2.16.3    2.6.4      
➜  homework git:(main) helm uninstall flux -n flux-system
release "flux" uninstalled
```