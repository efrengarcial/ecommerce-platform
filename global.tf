# Creates a network layer
resource "google_compute_network" "ecommerce-network" {
  name = "${var.platform-name}"
}