provider "packet" {
  version    = "1.3.2"
  auth_token = "${var.auth_token}"
}

resource "packet_project" "k3s_packet" {
  name = "Kubernetes (k3s ARM Lab)"
}

