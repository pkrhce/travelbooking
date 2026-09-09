variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "pk-sandbox-507311"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "travelbooking-gke"
}

variable "node_count" {
  description = "Initial number of GKE nodes per zone"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-standard-4"
}
