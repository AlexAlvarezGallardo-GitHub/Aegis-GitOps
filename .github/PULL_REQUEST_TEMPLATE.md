## Summary

Briefly describe what this change does and why.

## Changes

- List the concrete changes (charts, overlays, applications, docs, ...).

## Testing

- How was the change validated? (e.g. `helm template`, `kustomize build`, `helm lint`)
- Which environments are affected and how the change is promoted.

## Checklist

- [ ] Manifests are declarative and committed (no imperative cluster changes)
- [ ] Charts/overlays render with `helm template` / `kustomize build`
- [ ] No hardcoded secrets or credentials in the diff
- [ ] Image references use immutable tags
- [ ] Documentation kept in sync (README, environment matrix, promotion flow)
- [ ] Reviewed and approved; CI is green
