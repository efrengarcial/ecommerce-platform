# Creates a network layer
resource "google_compute_network" "ecommerce-network" {
  name = "${var.platform-name}"
  project  = "${var.gcloud-project}"
}

# Creates a firewall with some sane defaults, allowing ports 22, 80 and 443 to be open
# This is ssh, http and https.
resource "google_compute_firewall" "ssh" {
  name    = "${var.platform-name}-ssh"
  network = "${google_compute_network.ecommerce-network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

   source_ranges = ["0.0.0.0/0"]
}

# Creates a new subnet for our platform within our selected region
resource "google_compute_subnetwork" "ecommerce-subnetwork" {
  name          = "dev-${var.platform-name}-${var.gcloud-region}"
  ip_cidr_range = "10.1.2.0/24"
  network       = "${google_compute_network.ecommerce-network.self_link}"
  region        = "${var.gcloud-region}"
}

# Creates a container cluster called 'ecommerce-cluster'
# Attaches new cluster to our network and our subnet,
# Ensures at least one instance is running
resource "google_container_cluster" "ecommerce-cluster" {
  name = "ecommerce-cluster"
  network = "${google_compute_network.ecommerce-network.name}"
  subnetwork = "${google_compute_subnetwork.ecommerce-subnetwork.name}"
  zone = "${var.gcloud-zone}"

  initial_node_count = 1

  master_auth {
    username = "admin"
    password = "admin12345678910"
  }

  node_config {

    # Defines the type/size instance to use
    # Standard is a sensible starting point
    machine_type = "n1-standard-1"

    # Grants OAuth access to the following API's within the cluster
    oauth_scopes = [
      "https://www.googleapis.com/auth/projecthosting",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
