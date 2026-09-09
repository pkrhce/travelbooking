# ─────────────────────────────────────────────
# VPC Network
# ─────────────────────────────────────────────

resource "google_compute_network" "vpc" {
  name                    = "travelbooking-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = "travelbooking-subnet"
  ip_cidr_range = "10.0.0.0/20"
  region        = var.region
  network       = google_compute_network.vpc.id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.4.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.8.0.0/20"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "travelbooking-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}
