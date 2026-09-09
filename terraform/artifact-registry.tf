# ─────────────────────────────────────────────
# Artifact Registry
# ─────────────────────────────────────────────

resource "google_artifact_registry_repository" "docker" {
  location      = var.region
  repository_id = "travelbooking"
  description   = "Docker images for TravelBooking microservices"
  format        = "DOCKER"
  project       = var.project_id
}
