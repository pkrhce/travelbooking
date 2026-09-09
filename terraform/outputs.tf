# ─────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────

output "cluster_name" {
  value = google_container_cluster.gke.name
}

output "cluster_endpoint" {
  value     = google_container_cluster.gke.endpoint
  sensitive = true
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}"
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --region ${var.region} --project ${var.project_id}"
}
