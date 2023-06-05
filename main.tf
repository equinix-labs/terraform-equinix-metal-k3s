module "k3s_cluster" {
  source = "./modules/k3s_cluster"

  for_each = { for cluster in var.clusters : cluster.name => cluster }

  cluster_name            = each.key
  metro                   = each.value.metro
  plan_control_plane      = each.value.plan_control_plane
  plan_node               = each.value.plan_node
  node_count              = each.value.node_count
  k3s_ha                  = each.value.k3s_ha
  os                      = each.value.os
  control_plane_hostnames = each.value.control_plane_hostnames
  node_hostnames          = each.value.node_hostnames
  custom_k3s_token        = each.value.custom_k3s_token
  k3s_version             = each.value.k3s_version
  metallb_version         = each.value.metallb_version
  ip_pool_count           = each.value.ip_pool_count
  metal_auth_token        = var.metal_auth_token
  metal_project_id        = var.metal_project_id
  deploy_demo             = var.deploy_demo
  global_ip_cidr          = local.global_ip_cidr
}

resource "equinix_metal_reserved_ip_block" "global_ip" {
  project_id  = var.metal_project_id
  type        = "global_ipv4"
  quantity    = 1
  count       = var.global_ip ? 1 : 0
  description = "Global IP to Load Balance between all metros"
}

locals {
  global_ip_cidr = var.global_ip ? equinix_metal_reserved_ip_block.global_ip[0].cidr_notation : ""
  # tflint-ignore: terraform_unused_declarations
  validate_demo = (var.deploy_demo == true && var.global_ip == false) ? tobool("Demo is only deployed if global_ip = true.") : true
}
