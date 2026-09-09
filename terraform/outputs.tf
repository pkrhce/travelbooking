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

output "ingress_ip" {
  value = google_compute_global_address.ingress_ip.address
}

output "connect_to_cluster" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --region ${var.region} --project ${var.project_id}"
}

output "get_argocd_password" {
  value = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "get_sa_key" {
  value = "terraform output -raw github_actions_sa_key | base64 -d > github-actions-key.json"
}
