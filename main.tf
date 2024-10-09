locals {
  global_ip_cidr = var.global_ip ? equinix_metal_reserved_ip_block.global_ip[0].cidr_notation : ""
}

################################################################################
# K8s Cluster In-line Module
################################################################################

module "kube_cluster" {
  source = "./modules/kube_cluster"

  for_each = { for cluster in var.clusters : cluster.name => cluster }

  cluster_name            = each.key
  metal_metro             = each.value.metro
  plan_control_plane      = each.value.plan_control_plane
  plan_node               = each.value.plan_node
  node_count              = each.value.node_count
  ha                      = each.value.ha
  os                      = each.value.os
  control_plane_hostnames = each.value.control_plane_hostnames
  node_hostnames          = each.value.node_hostnames
  custom_token            = each.value.custom_token
  kube_version            = each.value.kube_version
  metallb_version         = each.value.metallb_version
  ip_pool_count           = each.value.ip_pool_count
  rancher_flavor          = each.value.rancher_flavor
  rancher_version         = each.value.rancher_version
  custom_rancher_password = each.value.custom_rancher_password
  metal_project_id        = var.metal_project_id
  deploy_demo             = var.deploy_demo
  global_ip_cidr          = local.global_ip_cidr
}

################################################################################
# Global IP
################################################################################

resource "equinix_metal_reserved_ip_block" "global_ip" {
  project_id  = var.metal_project_id
  type        = "global_ipv4"
  quantity    = 1
  count       = var.global_ip ? 1 : 0
  description = "Global IP to Load Balance between all metros"
}
