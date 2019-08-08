terraform {
  required_version = ">= 0.12.6"
}

provider "packet" {
  auth_token = "${var.auth_token}"
  version    = ">= 2.1.1"
}

resource "packet_reserved_ip_block" "anycast_ip" {
  project_id = "${var.project_id}"
  type       = "global_ipv4"
  quantity   = 1
  facility   = ""
}
