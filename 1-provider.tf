provider "packet" {
  version    = "1.3.2"
  auth_token = "${var.auth_token}"
}

resource "packet_project" "k3s_packet" {
  name = "Kubernetes (k3s ARM Lab)"
}

resource "packet_reserved_ip_block" "kubernetes" {
  project_id = "${packet_project.k3s_packet.id}"
  facility   = "${var.facility}"
  quantity   = 2
}
