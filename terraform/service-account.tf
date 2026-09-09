# Service Account for GitHub Actions (no JSON key — org policy blocks it)
# Instead, use Workload Identity Federation for keyless auth

resource "google_service_account" "github_actions" {
  account_id   = "github-actions"
  display_name = "GitHub Actions CI/CD"
  project      = var.project_id
}

resource "google_project_iam_member" "github_actions_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_actions_container_dev" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Workload Identity Federation — allows GitHub Actions to authenticate
# without a JSON key (keyless, more secure!)
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  project                   = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  project                            = var.project_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Allow GitHub Actions from YOUR repo to impersonate the SA
resource "google_service_account_iam_member" "github_actions_wif" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/pkrhce/travelbooking"
}

output "wif_provider" {
  description = "Use this value in GitHub Actions auth step"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_email" {
  description = "SA email for GitHub Actions"
  value       = google_service_account.github_actions.email
}
