variable "count" {}
variable "plan_primary" {}
variable "plan_node" {}
variable "facility" {}
variable "auth_token" {}
variable "project_id" {}
variable "cluster_name" {}
variable "ssh_private_key_path" {}

resource "packet_reserved_ip_block" "packet-k3s" {
  project_id = "${var.project_id}"
  facility   = "${var.facility}"
  quantity   = 2
}

data "template_file" "controller" {
  template = "${file("${path.module}/controller.tpl")}"

  vars {
    packet_network_cidr = "${packet_reserved_ip_block.packet-k3s.cidr_notation}"
    packet_auth_token   = "${var.auth_token}"
    packet_project_id   = "${var.project_id}"
  }
}

resource "packet_device" "k3s_primary" {
  hostname         = "packet-k3s-${var.cluster_name}-controller"
  operating_system = "ubuntu_16_04"
  plan             = "${var.plan_primary}"
  facility         = "${var.facility}"
  user_data        = "${data.template_file.controller.rendered}"

  billing_cycle = "hourly"
  project_id    = "${var.project_id}"
}

resource "packet_ip_attachment" "kubernetes_lb_block" {
  device_id     = "${packet_device.k3s_primary.id}"
  cidr_notation = "${packet_reserved_ip_block.packet-k3s.cidr_notation}"
}

data "external" "k3s_token" {
  program = ["bash", "${path.module}/get_k3s_token.sh"]

  query = {
    token        = "${packet_device.k3s_primary.network.0.address}"
    ssh_key_path = "${var.ssh_private_key_path}"
  }
}

data "template_file" "node" {
  template = "${file("${path.module}/node.tpl")}"

  vars {
    kube_token      = "${data.external.k3s_token.result["token"]}"
    primary_node_ip = "${packet_device.k3s_primary.network.0.address}"
  }
}

resource "packet_device" "arm_node" {
  hostname         = "${format("packet-k3s-${var.cluster_name}-%02d", count.index)}"
  operating_system = "ubuntu_16_04"
  count            = "${var.count}"
  plan             = "${var.plan_node}"
  facility         = "${var.facility}"
  user_data        = "${data.template_file.node.rendered}"

  billing_cycle = "hourly"
  project_id    = "${var.project_id}"
}
