module "cluster_nrt1" {
  source = "modules/cluster_pool"

  count                = "${var.count}"
  plan_primary         = "${var.plan_primary}"
  plan_node            = "${var.plan_node}"
  facility             = "${var.facility}"
  cluster_name         = "${var.cluster_name}"
  auth_token           = "${var.auth_token}"
  project_id           = "${packet_project.k3s_packet.id}"
  packet_network_block = "${packet_reserved_ip_block.kubernetes.cidr_notation}"
}
