variable "node_count" {}
variable "plan_primary" {}
variable "plan_node" {}
variable "facility" {}
variable "auth_token" {}
variable "project_id" {}
variable "cluster_name" {}
variable "ssh_private_key_path" {}
variable "anycast_ip" {}

resource "packet_reserved_ip_block" "packet-k3s" {
  project_id = "${var.project_id}"
  facility   = "${var.facility}"
  quantity   = 2
}

data "template_file" "controller" {
  template = "${file("${path.module}/controller.tpl")}"

  vars = {
    packet_network_cidr = "${packet_reserved_ip_block.packet-k3s.cidr_notation}"
    packet_auth_token   = "${var.auth_token}"
    packet_project_id   = "${var.project_id}"
    anycast_ip          = "${var.anycast_ip}"
  }
}

resource "packet_device" "k3s_primary" {
  hostname         = "packet-k3s-${var.cluster_name}-${var.facility}-controller"
  operating_system = "ubuntu_16_04"
  plan             = "${var.plan_primary}"
  facilities       = ["${var.facility}"]
  user_data        = "${data.template_file.controller.rendered}"

  provisioner "local-exec" {
    command = "scp -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null scripts/create_bird_conf.sh root@${self.access_public_ipv4}:/root/create_bird_conf.sh"
  }

  billing_cycle = "hourly"
  project_id    = "${var.project_id}"
}

resource "packet_bgp_session" "test" {
  device_id      = "${packet_device.k3s_primary.id}"
  address_family = "ipv4"
}

resource "packet_ip_attachment" "kubernetes_lb_block" {
  device_id     = "${packet_device.k3s_primary.id}"
  cidr_notation = "${packet_reserved_ip_block.packet-k3s.cidr_notation}"
}

data "template_file" "node" {
  template = "${file("${path.module}/node.tpl")}"

  vars = {
    primary_node_ip = "${packet_device.k3s_primary.network.0.address}"
  }
}

resource "packet_device" "arm_node" {
  hostname         = "${format("packet-k3s-${var.cluster_name}-${var.facility}-%02d", count.index)}"
  operating_system = "ubuntu_16_04"
  count            = "${var.node_count}"
  plan             = "${var.plan_node}"
  facilities       = ["${var.facility}"]
  user_data        = "${data.template_file.node.rendered}"

  provisioner "local-exec" {
    command = "scp -3 -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@${packet_device.k3s_primary.network.0.address}:/var/lib/rancher/k3s/server/node-token root@${self.access_public_ipv4}:node-token"
  }

  billing_cycle = "hourly"
  project_id    = "${var.project_id}"
}
