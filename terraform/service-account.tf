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

resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions.name
}

output "github_actions_sa_key" {
  description = "SA JSON key for GitHub. Decode: terraform output -raw github_actions_sa_key | base64 -d"
  value       = google_service_account_key.github_actions_key.private_key
  sensitive   = true
}
