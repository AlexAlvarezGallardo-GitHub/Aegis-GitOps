# Security Policy

Aegis-GitOps manages the deployment configuration of a demonstration financial platform. Because this repository is the entry point to the cluster, security is applied at the same standard as the rest of the Aegis platform: defense-in-depth through the software supply chain and the GitOps delivery model.

## Supported Versions

This repository is continuously developed. Only the latest commit on `main` receives security fixes.

| Version | Supported |
|---------|-----------|
| `main` (latest) | :white_check_mark: |
| Previous releases | :x: |

## Reporting a Vulnerability

Please **do not open a public issue** for security problems.

If you find a vulnerability, use one of these private channels:

1. **GitHub Private Vulnerability Reporting** (preferred) — the repository enables the "Security" tab → "Report a vulnerability" flow.
2. **Email** the maintainer directly: `alexag1999@gmail.com`.

### What to include

- Affected component and commit SHA if possible.
- Type of vulnerability and severity assessment.
- Steps to reproduce (minimal, no production data).
- Any proof-of-concept you are comfortable sharing.

### What happens next

- Acknowledgment within **48 hours**.
- Confirmation and triage within **5 business days**.
- A coordinated disclosure timeline is agreed before any public notice.
- The reporter is credited (unless they prefer anonymity).

## Security Model

This repository is the deployment contract of the cluster. Security is enforced through the following practices:

| Layer | Practice |
|-------|----------|
| **Delivery** | Cluster changes only via pull request + Argo CD sync; no direct cluster access |
| **Secrets** | No secrets in manifests — credentials are injected via Kubernetes secrets / GitHub Actions secrets, never committed |
| **Images** | Immutable SHAs referenced from GHCR; pull secrets scoped per namespace (`ghcr-pull`) |
| **RBAC** | Argo CD applications use the `default` project with explicit sync policies |
| **Approval gates** | STAGE and PROD use manual/approval sync so production changes are human-reviewed |
| **Prune protection** | PROD has `prune: false` — destructive removals require an explicit decision |

## Disclosure Policy

This is a personal/portfolio codebase. We follow a responsible-disclosure model: no exploit hunting outside your own deployments, no disclosure to third parties until the maintainer has had a reasonable window to fix the issue.
