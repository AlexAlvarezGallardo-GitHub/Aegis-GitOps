<#
.SYNOPSIS
    Sets up a local Minikube cluster with Argo CD and deploys Aegis environments via GitOps.

.DESCRIPTION
    Creates the cluster, installs Argo CD, creates the GHCR pull secret, and applies
    the Aegis App of Apps. With -Environment, it deploys ONLY that environment.

.PARAMETER Environment
    Deploy only this environment (dev, pre, stage, prod). If omitted, all environments are deployed.

.PARAMETER User
    GitHub username for GHCR authentication. If omitted, you will be prompted.

.PARAMETER Pat
    GitHub Personal Access Token with read:packages scope. If omitted, you will be prompted.

.PARAMETER SkipArgocd
    Skip Argo CD installation (assumes it is already installed and running).

.PARAMETER Destroy
    Delete the minikube cluster instead of creating it.

.PARAMETER ClusterName
    Minikube cluster name (default: minikube).

.EXAMPLE
    ./setup-minikube.ps1 -Environment pre -User myuser -Pat ghp_xxx
    Deploys ONLY the PRE environment with a GHCR pull secret.

.EXAMPLE
    ./setup-minikube.ps1 -User myuser -Pat ghp_xxx
    Deploys all environments (dev, pre, stage, prod).
#>
param(
    [ValidateSet("dev", "pre", "stage", "prod")]
    [string]$Environment,
    [string]$User,
    [string]$Pat,
    [switch]$SkipArgocd,
    [switch]$Destroy,
    [string]$ClusterName = "minikube"
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

function Write-Step { param([string]$Msg) Write-Host "`n==> $Msg" -ForegroundColor Cyan }
function Write-Err { param([string]$Msg) Write-Host "ERROR: $Msg" -ForegroundColor Red }

function Test-Tool {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Err "$Name is required but was not found. Install it and retry."
        exit 1
    }
}

# ── Validate tools ────────────────────────────────────────────────
Write-Step "Validating tools"
Test-Tool "minikube"
Test-Tool "kubectl"
Test-Tool "helm"

# ── Destroy mode ──────────────────────────────────────────────────
if ($Destroy) {
    Write-Step "Deleting minikube cluster '$ClusterName'"
    minikube delete -p $ClusterName
    Write-Host "Cluster deleted."
    exit 0
}

# ── Determine environments ────────────────────────────────────────
if ($Environment) {
    $Environments = @($Environment)
    Write-Step "Targeting environment: $Environment"
} else {
    $Environments = @("dev", "pre", "stage", "prod")
    Write-Step "Targeting all environments: $($Environments -join ', ')"
}

# ── GHCR credentials ──────────────────────────────────────────────
if (-not $User) { $User = Read-Host "GitHub username for GHCR" }
if (-not $Pat) {
    $Pat = Read-Host -AsSecureString "GitHub PAT (read:packages)"
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Pat)
    $Pat = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

# ── Start cluster ─────────────────────────────────────────────────
Write-Step "Starting minikube cluster '$ClusterName'"
minikube start -p $ClusterName --cpus 4 --memory 8192
kubectl config use-context $ClusterName

# ── Namespaces ────────────────────────────────────────────────────
Write-Step "Creating namespaces"
foreach ($ns in (@("argocd") + $Environments | ForEach-Object { "aegis-$_" })) {
    kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f - | Out-Null
}
Write-Host "Namespaces ready: argocd, aegis-$($Environments -join ', aegis-')"

# ── GHCR pull secret per environment ──────────────────────────────
Write-Step "Creating GHCR pull secret (ghcr-pull)"
foreach ($env in $Environments) {
    $ns = "aegis-$env"
    $exists = kubectl get secret ghcr-pull -n $ns --ignore-not-found
    if ($exists) {
        Write-Host "ghcr-pull already exists in $ns"
        continue
    }
    kubectl create secret docker-registry ghcr-pull -n $ns `
        --docker-server=ghcr.io `
        --docker-username=$User `
        --docker-password=$Pat | Out-Null
    Write-Host "ghcr-pull created in $ns"
}

# ── Install Argo CD ───────────────────────────────────────────────
if (-not $SkipArgocd) {
    Write-Step "Installing Argo CD (kustomize)"
    kubectl apply -k "$RepoRoot\infrastructure\argocd\install"
    Write-Host "Waiting for argocd-server..."
    kubectl -n argocd wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s
}

# ── Apply applications ────────────────────────────────────────────
if ($Environment) {
    Write-Step "Applying applications for environment: $Environment"
    kubectl -n argocd apply -f "$RepoRoot\applications\$Environment\"
} else {
    Write-Step "Applying App of Apps (all environments)"
    kubectl -n argocd apply -f "$RepoRoot\applications\aegis-app-of-apps.yaml"
}

# ── Dashboard access ──────────────────────────────────────────────
Write-Step "Argo CD access"
$password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>$null
if ($password) {
    $plain = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($password))
    Write-Host "User:     admin"
    Write-Host "Password: $plain"
} else {
    Write-Host "Could not read admin password (secret may need time to appear)."
}
Write-Host ""
Write-Host "Start the dashboard with:"
Write-Host "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
Write-Host "  -> https://localhost:8080"

Write-Host ""
Write-Host "Done. Environments deployed: $($Environments -join ', ')"
