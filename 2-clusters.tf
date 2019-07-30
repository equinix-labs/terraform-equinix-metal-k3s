#Your Initial Cluster is defined here, subsequent clusters inventoried in 3-cluster-inventory.tf, created by Makefile
module "cluster_facility" {
  source = "./modules/cluster_pool"

  cluster_name         = "primary"
  node_count           = "${var.node_count}"
  plan_primary         = "${var.plan_primary}"
  plan_node            = "${var.plan_node}"
  facility             = "${var.facility}"
  auth_token           = "${var.auth_token}"
  project_id           = "${var.project_id}"
  ssh_private_key_path = "${var.ssh_private_key_path}"
  anycast_ip           = "${packet_reserved_ip_block.anycast_ip.address}"
}
