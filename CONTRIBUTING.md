# Contributing to Aegis-GitOps

Thank you for your interest in contributing to Aegis-GitOps. This guide defines how to
contribute, what is expected from you, and how your changes are reviewed and merged.

Aegis-GitOps is the **deployment contract** of the Aegis platform: every change in this
repository ends up running in a cluster. Treat it with the care you would give production
infrastructure — because that is exactly what it is.

---

## Table of Contents

1. [Development Requirements](#development-requirements)
2. [Project Conventions](#project-conventions)
3. [Branches](#branches)
4. [Commit Messages](#commit-messages)
5. [Pull Requests](#pull-requests)
6. [Validating Manifest Changes](#validating-manifest-changes)
7. [Definition of Done](#definition-of-done)
8. [Dependency Policy](#dependency-policy)
9. [AI-Assisted Development](#ai-assisted-development)
10. [Getting Help](#getting-help)

---

## Development Requirements

| Tool | Purpose |
|------|---------|
| kubectl | Interact with the cluster and validate manifests |
| Helm | Render and lint the service charts |
| Kustomize | Build overlays |
| Minikube (optional) | Local cluster for end-to-end validation |

### First-time setup

```bash
git config core.hooksPath .githooks   # if the repo ships local hooks
```

---

## Project Conventions

Aegis-GitOps follows the same engineering standards as the [Aegis](https://github.com/AlexAlvarezGallardo-GitHub/Aegis) platform:

- **GitOps-first**: all cluster changes are declarative and committed to Git.
- **Mermaid, not ASCII**: all architecture and flow diagrams use ` ```mermaid ` blocks.
- **No hardcoded secrets**: credentials come from Kubernetes secrets or CI secret stores.
- **Immutable tags**: deployments reference image SHAs, never `latest`.

---

## Branches

- `main` is the only long-lived branch and must always represent a deployable, valid state.
- Create feature branches from `main` and merge via pull request.
- Branch naming: `<type>/<short-description>` (lowercase kebab-case).

| Type | Use for |
|------|---------|
| `feature/` | New charts, overlays or infrastructure components |
| `fix/` | Bug fixes to manifests or configuration |
| `chore/` | Maintenance, image tag updates, tooling |
| `refactor/` | Manifest restructuring without behavior change |
| `docs/` | Documentation-only changes |

---

## Commit Messages

Format: `<type>(<scope>): <description>`

```text
feat(infra): add redis session store for dev overlay
fix(frontend): correct nginx upstream for pre
docs: document environment promotion flow
chore(infra): update dev image tags to <sha>
```

- **Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`, `perf`, `security`
- **Scopes**: `identity`, `wallet`, `bff`, `frontend`, `infra`, `observability`, `argocd`
- Description: lowercase, imperative mood, no period, max 72 chars.
- Reference issues in the footer: `Closes #42`.

---

## Pull Requests

- **One PR per change.** Keep PRs small and focused.
- PR title follows the same `<type>(<scope>): <description>` format as commits.
- PR body **must** include the sections from `.github/pull_request_template.md`:
  Summary, Changes, Testing, and Checklist.
- At least **one approval** is required before merging.
- Merge with **squash** to keep history clean.

> For infrastructure changes, reviewers must be able to trace what the change
> affects in the cluster and how it was validated.

---

## Validating Manifest Changes

Before opening a PR, validate that the change renders correctly:

```bash
# Render a chart with an environment overlay
helm template bff overlays/dev/bff-values.yaml --values overlays/dev/bff-values.yaml \
  --namespace aegis-dev

# Build a Kustomize overlay
kustomize build overlays/dev

# Lint a chart
helm lint charts/bff
```

Argo CD Applications must point to existing paths, and every path referenced in
`applications/` must exist on `main` before the app can sync.

---

## Definition of Done

A change is considered done when **all** of the following are true:

- [ ] Manifests are declarative and committed (no imperative cluster changes)
- [ ] Charts/overlays render with `helm template` / `kustomize build`
- [ ] No hardcoded secrets or credentials in the diff
- [ ] Image references use immutable tags
- [ ] Documentation kept in sync (README, environment matrix, promotion flow)
- [ ] Reviewed and approved; CI is green

---

## Dependency Policy

- Helm chart versions follow semantic versioning and are bumped on breaking template changes.
- Container image tags are managed by the Aegis CI `gitops-update` job; manual tag bumps must
  reference a real GHCR build.

---

## AI-Assisted Development

Aegis is built through an **AI-assisted engineering workflow with human ownership** of
architecture, validation and technical decisions. If you use AI tools:

- **You are responsible** for every manifest merged, even AI-generated ones.
- Validate AI output against the repository conventions.
- Never paste secrets, tokens or personal data into AI prompts.
- AI-generated changes must pass the same validation as hand-written ones.

---

## Getting Help

- Issues: [GitHub Issues](https://github.com/AlexAlvarezGallardo-GitHub/Aegis-GitOps/issues)
- Security reports: see [`SECURITY.md`](SECURITY.md)
- Application code and conventions: [Aegis](https://github.com/AlexAlvarezGallardo-GitHub/Aegis)

Please be respectful and constructive. This is a portfolio reference architecture,
not a commercial product — feedback that improves engineering quality is always welcome.
