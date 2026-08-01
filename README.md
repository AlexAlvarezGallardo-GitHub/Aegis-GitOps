# Aegis-GitOps

Declarative, Git-driven deployment configuration for the Aegis platform. This repository is part of the Aegis platform and follows the same documentation and architecture standards as every Aegis repository.

## Architecture

```mermaid
graph TB
    subgraph AppRepo[Code Repository: Aegis]
        AppCode[Application Code]
        CI[GitHub Actions CI]
    end

    subgraph Registry[Container Registry]
        GHCR[(GitHub Container Registry)]
    end

    subgraph GitOpsRepo[GitOps Repository: Aegis-GitOps]
        Charts[Helm Charts]
        Overlays[Kustomize Overlays]
        ArgoApp[Argo CD Application]
    end

    subgraph Cluster[Kubernetes Cluster]
        ArgoCD[Argo CD]
        DEV[DEV Namespace]
        PRE[PRE Namespace]
        STAGE[STAGE Namespace]
        PROD[PROD Namespace]
    end

    AppCode -->|push to main| CI
    CI -->|docker push| GHCR
    CI -->|update image tags| Overlays
    GHCR --> ArgoCD
    Charts --> Overlays
    Overlays --> ArgoApp
    ArgoCD -->|sync| DEV
    ArgoCD -->|sync| PRE
    ArgoCD -->|sync| STAGE
    ArgoCD -->|sync| PROD

    style AppCode fill:#bbf,color:#000
    style CI fill:#bbf,color:#000
    style GHCR fill:#fdb,color:#000
    style Charts fill:#bbf,color:#000
    style Overlays fill:#bbf,color:#000
    style ArgoApp fill:#bbf,color:#000
    style ArgoCD fill:#fdb,color:#000
    style DEV fill:#afa,color:#000
    style PRE fill:#afa,color:#000
    style STAGE fill:#afa,color:#000
    style PROD fill:#afa,color:#000
```

## Deployment Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant CI as GitHub Actions CI
    participant GHCR as GitHub Container Registry
    participant GitOps as Aegis-GitOps
    participant Argo as Argo CD
    participant K8s as Kubernetes (DEV)

    Dev->>CI: Push to main
    CI->>CI: Build & test
    CI->>GHCR: Push Docker images
    CI->>GitOps: Update image tags (overlays/dev)
    GitOps-->>Argo: Detect manifest change
    Argo->>Argo: Sync DEV application
    Argo->>K8s: Apply manifests
    K8s-->>Argo: Deployment status
    Argo-->>GitOps: Sync result
```

## Repository structure

```mermaid
graph TB
    Repo[Aegis-GitOps] --> Charts[charts/]
    Repo --> Base[base/]
    Repo --> Overlays[overlays/]
    Repo --> Apps[applications/]
    Repo --> Infra[infrastructure/]

    Charts --> ChIdentity[identity/]
    Charts --> ChWallet[wallet/]
    Charts --> ChBff[bff/]
    Charts --> ChFrontend[frontend/]

    Base --> BaseValues[values.yaml + kustomization.yaml]

    Overlays --> ODev[dev/]
    Overlays --> OPre[pre/]
    Overlays --> OStage[stage/]
    Overlays --> OProd[prod/]

    Apps --> AppsDev[dev/]

    style Repo fill:#fdb,color:#000
```

## Helm charts

Each service has a standalone Helm chart under `charts/<service>/` with the following templates:

- `deployment.yaml` - replicas, image, probes, resources, affinity, tolerations
- `service.yaml` - ClusterIP service on the service port
- `configmap.yaml` - environment variables from `.Values.config`
- `ingress.yaml` - optional ingress (enabled via `.Values.ingress.enabled`)
- `hpa.yaml` - optional HorizontalPodAutoscaler (`.Values.autoscaling.enabled`)
- `pdb.yaml` - optional PodDisruptionBudget (`.Values.podDisruptionBudget.enabled`)

## Overlay strategy

Environment-specific configuration is provided via Helm value files in each overlay. Argo CD applications point a chart at `overlays/<env>/<service>-values.yaml`.

| Parameter | DEV | PRE | STAGE | PROD |
|-----------|-----|-----|-------|------|
| Replicas | 1 | 2 | 2 | 3 (HPA 3-10) |
| CPU request | 100m | 250m | 250m | 500m |
| Memory request | 128Mi | 256Mi | 256Mi | 512Mi |
| HPA | No | No | No | Yes |
| PDB | No | No | Yes (1) | Yes (2) |
| Affinity | No | No | No | Yes (anti-affinity) |

## Environments

| Environment | Overlay | Namespace | Status |
|-------------|---------|-----------|--------|
| DEV         | `overlays/dev/`   | `aegis-dev`   | Active |
| PRE         | `overlays/pre/`   | `aegis-pre`   | Stub   |
| STAGE       | `overlays/stage/` | `aegis-stage` | Stub   |
| PROD        | `overlays/prod/`  | `aegis-prod`  | Stub   |

## Argo CD and Environment Promotion

Argo CD is bootstrapped via GitOps and manages every application through an **App of Apps** pattern.

```mermaid
graph TB
    Root[App of Apps] --> Dev[DEV Applications]
    Root --> Pre[PRE Applications]
    Root --> Stage[STAGE Applications]
    Root --> Prod[PROD Applications]
    Root --> Mon[Monitoring]
    Root --> Log[Logging]

    Dev --> DevS[identity, wallet, bff, frontend]
    Pre --> PreS[identity, wallet, bff, frontend]
    Stage --> StageS[identity, wallet, bff, frontend]
    Prod --> ProdS[identity, wallet, bff, frontend]

    style Root fill:#fdb,color:#000
    style Dev fill:#bbf,color:#000
    style Pre fill:#bbf,color:#000
    style Stage fill:#bbf,color:#000
    style Prod fill:#bbf,color:#000
    style Mon fill:#bbf,color:#000
    style Log fill:#bbf,color:#000
```

### Sync policies

| Environment | Sync | Prune | Self-Heal |
|-------------|------|-------|-----------|
| DEV   | Auto  | Yes | Yes |
| PRE   | Auto  | Yes | Yes |
| STAGE | Manual/Approval | Yes | Yes |
| PROD  | Manual/Approval | No  | Yes |

### Promotion flow

```mermaid
graph LR
    A[DEV] -->|auto| B[PRE]
    B -->|approval| C[STAGE]
    C -->|approval| D[PROD]
    style A fill:#afa,color:#000
    style B fill:#afa,color:#000
    style C fill:#afa,color:#000
    style D fill:#afa,color:#000
```

Promotion is declarative: updating the image tag in `overlays/<env>/*-values.yaml` in Git is the promotion. Argo CD syncs DEV and PRE automatically; STAGE and PROD require a manual sync (approval gate).

### Bootstrap

Apply the bootstrap application once, then Argo CD self-manages everything:

```
kubectl apply -k infrastructure/argocd/install
kubectl -n argocd apply -f applications/aegis-app-of-apps.yaml
```

## Local Development (minikube)

### Prerequisites

- Docker, Minikube, kubectl, Helm, JDK 21
- A GitHub PAT with `read:packages` scope to pull private GHCR images

### 1. Create the cluster

```bash
minikube start --cpus 4 --memory 8192
```

### 2. Create the GHCR pull secret in every environment namespace

```bash
kubectl create namespace aegis-dev aegis-pre aegis-stage aegis-prod argocd
for ns in aegis-dev aegis-pre aegis-stage aegis-prod; do
  kubectl create secret docker-registry ghcr-pull -n $ns \
    --docker-server=ghcr.io \
    --docker-username=<your-user> \
    --docker-password=<PAT>
done
```

The charts reference this secret via `imagePullSecrets[].name = ghcr-pull` in the environment overlays.

### 3. Install Argo CD

```bash
kubectl apply -k infrastructure/argocd/install
# wait for pods
kubectl wait -n argocd --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s
```

### 4. Bootstrap the App of Apps

```bash
kubectl -n argocd apply -f applications/aegis-app-of-apps.yaml
```

### 5. Access the dashboard

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
kubectl port-forward svc/argocd-server -n argocd 8080:443
# https://localhost:8080  (user: admin)
```

### 6. Promote between environments

Update the image `tag` in `overlays/<env>/*-values.yaml`. DEV and PRE auto-sync; STAGE and PROD require a manual sync (approval gate).

## Image tag updates