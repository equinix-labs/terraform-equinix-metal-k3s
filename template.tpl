module "cluster_NAME_REGION" {
  source = "modules/cluster_pool"
  
  cluster_name 	       = "NAME"
  count                = "${var.count}"
  plan_primary         = "${var.plan_primary}"
  plan_node            = "${var.plan_node}"
  facility             = "REGION"
  auth_token           = "${var.auth_token}"
  project_id           = "${var.project_id}"
  ssh_private_key_path = "${var.ssh_private_key_path}"
  anycast_ip           = "${packet_reserved_ip_block.anycast_ip.address}"
}
