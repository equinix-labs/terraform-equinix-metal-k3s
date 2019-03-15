provider "packet" {
  auth_token = "${var.auth_token}"
}

resource "packet_reserved_ip_block" "anycast_ip" {
  project_id = "${var.project_id}"
  type       = "global_ipv4"
  quantity   = 1
  facility   = ""
}
