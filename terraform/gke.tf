# ─────────────────────────────────────────────
# GKE Cluster with Dataplane V2 (Cilium)
# ─────────────────────────────────────────────

resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Remove default node pool — we create our own
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Enable Dataplane V2 (Cilium CNI)
  datapath_provider = "ADVANCED_DATAPATH"

  # Networking config
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Enable Network Policy (enforced by Cilium)
  network_policy {
    enabled  = true
    provider = "PROVIDER_UNSPECIFIED"
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Release channel
  release_channel {
    channel = "REGULAR"
  }

  # Vertical Pod Autoscaler
  vertical_pod_autoscaling {
    enabled = true
  }

  # Gateway API
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
}

# ─────────────────────────────────────────────
# Node Pool
# ─────────────────────────────────────────────

resource "google_container_node_pool" "primary" {
  name       = "primary-pool"
  location   = var.region
  cluster    = google_container_cluster.gke.name
  project    = var.project_id
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      environment = "production"
      project     = "travelbooking"
    }
  }

  autoscaling {
    min_node_count = 2
    max_node_count = 6
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
