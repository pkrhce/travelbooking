# ─────────────────────────────────────────────
# Global Static IP for Gateway/Ingress
# ─────────────────────────────────────────────

resource "google_compute_global_address" "ingress_ip" {
  name    = "travelbooking-ingress-ip"
  project = var.project_id
}

output "ingress_ip" {
  value = google_compute_global_address.ingress_ip.address
}
