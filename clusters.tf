module "cluster_facility" {
  source = "./modules/cluster_pool"

  cluster_name         = var.cluster_name
  node_count           = var.node_count
  plan_primary         = var.plan_primary
  plan_node            = var.plan_node
  facilities           = var.facilities
  primary_facility     = var.primary_facility
  auth_token           = var.auth_token
  project_id           = var.project_id
  ssh_private_key_path = var.ssh_private_key_path
  anycast_ip           = packet_reserved_ip_block.anycast_ip.address
}
