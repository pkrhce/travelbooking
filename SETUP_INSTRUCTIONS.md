# TravelBooking — GCP DevOps Project Setup

## Step 1: Mirror the Original Repo

```bash
# Create a new empty repo on GitHub: https://github.com/new
# Name: travelbooking | Do NOT initialize with README

# Mirror the original repo
git clone --bare https://github.com/vijaygiduthuri/travelbooking.git
cd travelbooking.git
git push --mirror https://github.com/YOUR_USERNAME/travelbooking.git
cd ..
rm -rf travelbooking.git

# Clone YOUR new repo
git clone https://github.com/YOUR_USERNAME/travelbooking.git
cd travelbooking
```

## Step 2: Remove Jenkins-Related Files

```bash
# Remove Jenkins pipeline and configs (replaced by GitHub Actions)
rm -f Jenkinsfile
rm -rf jenkins/
git add -A
git commit -m "chore: remove Jenkins (replaced by GitHub Actions + ArgoCD)"
```

## Step 3: Add New Files from This Package

```bash
# Copy the files from this package into your repo:
# - .github/workflows/ci-all-services.yaml
# - terraform/ (entire directory)
# - README.md (replace existing)

git add .
git commit -m "feat: add GitHub Actions CI, Terraform IaC, and project docs"
git push origin main
```

## Step 4: Create the GitOps Repo

```bash
# Create another repo on GitHub: travelbooking-gitops
# Clone and copy all files from the travelbooking-gitops/ directory in this package

git clone https://github.com/YOUR_USERNAME/travelbooking-gitops.git
cd travelbooking-gitops
# Copy all files from travelbooking-gitops/ folder
git add .
git commit -m "feat: initialize GitOps repo with Helm charts and ArgoCD apps"
git push origin main
```

## Step 5: Configure GitHub Secrets

Go to your travelbooking repo → Settings → Secrets and variables → Actions:

| Secret | Value |
|--------|-------|
| GCP_PROJECT_ID | Your GCP project ID |
| GCP_SA_KEY | Service account JSON key |
| GCP_REGION | e.g., asia-south1 |
| GITOPS_PAT | GitHub PAT with repo write access |

## Step 6: Deploy Infrastructure

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

## Step 7: Bootstrap ArgoCD

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Apply the app-of-apps (from GitOps repo)
kubectl apply -f apps/app-of-apps.yaml
```

That's it! Push any code change and watch the full CI/CD flow in action.
