# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Professional repository standards**: full rewrite of the README, MIT `LICENSE.md`,
  `SECURITY.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md`, `.gitignore`
  and a pull request template under `.github/`.

## [0.4.0] - 2026-08-05

### Added

- **Observability stack** managed via GitOps: Prometheus, Grafana, Alertmanager, Tempo,
  Loki + Promtail, kube-state-metrics and node-exporter under `infrastructure/`.
- Grafana dashboards for system overview, JVM, HTTP requests and Kafka consumers.
- Argo CD `monitoring` and `logging` applications.
- OTLP tracing endpoint wired into service overlays.

## [0.3.0] - 2026-08-03

### Added

- PostgreSQL managed via GitOps for the identity and wallet bounded contexts
  (`infrastructure/database/`, base + overlays).
- Kafka + ZooKeeper managed via GitOps (`infrastructure/kafka/`).
- Redis session store for the BFF (`infrastructure/redis/`).
- DEV app-of-apps (`applications/app-of-apps-dev.yaml`).

### Fixed

- Frontend nginx upstream pointed to the BFF service across all environments.
- Identity datasource configured for the in-cluster PostgreSQL.
- Probe delays and resource limits tuned to prevent OOM kills and startup failures.

## [0.2.0] - 2026-08-01

### Added

- Reusable Helm charts for identity, wallet, BFF and frontend (`charts/`).
- Environment overlays for DEV, PRE, STAGE and PROD with Helm value files.
- Argo CD App of Apps bootstrap and environment promotion.
- GHCR `imagePullSecrets` in environment overlays.
- `scripts/setup-minikube.ps1` for local GitOps testing.

### Changed

- README migrated to the Aegis Mermaid documentation standards.

## [0.1.0] - 2026-07-31

### Added

- Initial repository scaffold: base Kustomize manifests, environment overlays and
  Argo CD installation manifests.
- First README describing the GitOps architecture.
