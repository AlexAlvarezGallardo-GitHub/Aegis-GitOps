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

    style AppCode fill:#bbf
    style CI fill:#bbf
    style GHCR fill:#fdb
    style Charts fill:#bbf
    style Overlays fill:#bbf
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

    style Repo fill:#fdb
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

## Image tag updates

The CI pipeline in `Aegis` updates the image `tag` in `overlays/dev/*-values.yaml` with the latest image tag after every merge to `main`.

Images are hosted at `ghcr.io/AlexAlvarezGallardo-GitHub/`.