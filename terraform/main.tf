# ─────────────────────────────────────────────
# Provider Configuration
# ─────────────────────────────────────────────

terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }

  # Uncomment for remote state (recommended)
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "travelbooking"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Configure Helm provider after GKE is created
provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
  }
}

data "google_client_config" "default" {}
