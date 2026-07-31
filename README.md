# Aegis-GitOps

Declarative, Git-driven deployment configuration for the Aegis platform.

## Repository structure

```
.
|-- applications/          # Argo CD Application manifests
|   |-- dev/
|   -- platform/
|-- base/                  # Shared base Kubernetes manifests per service
|   |-- identity/
|   |-- wallet/
|   |-- bff/
|   -- frontend/
|-- overlays/              # Environment-specific Kustomize overlays
|   |-- dev/
|   |-- pre/
|   |-- stage/
|   -- prod/
-- infrastructure/        # Shared platform infrastructure
    -- argocd/
```

## Flow

```
Merge to main (Aegis)
      |
      v
Build & push Docker images to GHCR
      |
      v
Update image tags in overlays/dev/
      |
      v
Argo CD syncs the dev environment
      |
      v
Deploy to Kubernetes (DEV)
```

## Environments

| Environment | Overlay | Status |
|-------------|---------|--------|
| DEV         | overlays/dev/   | Active |
| PRE         | overlays/pre/   | Stub   |
| STAGE       | overlays/stage/ | Stub   |
| PROD        | overlays/prod/  | Stub   |

## Image tag updates

The CI pipeline in Aegis updates overlays/dev/kustomization.yaml with the latest image tag after every merge to main.

Images are hosted at ghcr.io/AlexAlvarezGallardo-GitHub/.