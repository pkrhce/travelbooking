# ─────────────────────────────────────────────
# Input Variables
# ─────────────────────────────────────────────

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-south1-a"
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "travelbooking-gke"
}

variable "node_count" {
  description = "Number of GKE nodes"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-standard-4"
}
