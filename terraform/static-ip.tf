resource "google_compute_global_address" "ingress_ip" {
  name    = "travelbooking-ingress-ip"
  project = var.project_id
}
