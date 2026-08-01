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
        Manifests[Kubernetes Manifests]
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
    CI -->|update image tags| Manifests
    GHCR --> ArgoCD
    Manifests --> ArgoCD
    ArgoApp --> ArgoCD
    ArgoCD -->|sync| DEV
    ArgoCD -->|sync| PRE
    ArgoCD -->|sync| STAGE
    ArgoCD -->|sync| PROD

    style AppCode fill:#bbf
    style CI fill:#bbf
    style GHCR fill:#fdb
    style Manifests fill:#bbf
    style ArgoApp fill:#bbf
    style ArgoCD fill:#fdb
    style DEV fill:#afa
    style PRE fill:#afa
    style STAGE fill:#afa
    style PROD fill:#afa
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
    Repo[Aegis-GitOps] --> Apps[applications/]
    Repo --> Base[base/]
    Repo --> Overlays[overlays/]
    Repo --> Infra[infrastructure/]

    Apps --> AppsDev[dev/]
    Apps --> AppsPlatform[platform/]
    Base --> BaseIdentity[identity/]
    Base --> BaseWallet[wallet/]
    Base --> BaseBff[bff/]
    Base --> BaseFrontend[frontend/]
    Overlays --> OverlaysDev[dev/]
    Overlays --> OverlaysPre[pre/]
    Overlays --> OverlaysStage[stage/]
    Overlays --> OverlaysProd[prod/]
    Infra --> InfraArgocd[argocd/]

    style Repo fill:#fdb
```

## Environments

| Environment | Overlay | Status |
|-------------|---------|--------|
| DEV         | `overlays/dev/`   | Active |
| PRE         | `overlays/pre/`   | Stub   |
| STAGE       | `overlays/stage/` | Stub   |
| PROD        | `overlays/prod/`  | Stub   |

## Image tag updates

The CI pipeline in `Aegis` updates `overlays/dev/kustomization.yaml` with the latest image tag after every merge to `main`.

Images are hosted at `ghcr.io/AlexAlvarezGallardo-GitHub/`.