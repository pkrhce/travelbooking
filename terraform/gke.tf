resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  datapath_provider = "ADVANCED_DATAPATH"

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Private cluster — no external IPs on nodes (required by org policy)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Allow Cloud Shell to access the master
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All (for Cloud Shell access)"
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  deletion_protection = false
}

resource "google_container_node_pool" "primary" {
  name     = "primary-pool"
  location = var.region
  cluster  = google_container_cluster.gke.name
  project  = var.project_id

  initial_node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50
    disk_type    = "pd-standard"

    # Shielded VM — required by org policy
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      environment = "dev"
      project     = "travelbooking"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# NAT Gateway — private nodes need this for internet access (pull images, etc.)
resource "google_compute_router" "router" {
  name    = "travelbooking-router"
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "travelbooking-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
