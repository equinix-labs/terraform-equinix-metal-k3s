locals {
  k3s_token    = coalesce(var.custom_k3s_token, random_string.random_k3s_token.result)
  api_vip      = var.k3s_ha ? equinix_metal_reserved_ip_block.api_vip_addr[0].address : equinix_metal_device.all_in_one[0].network[0].address
  ip_pool_cidr = var.ip_pool_count > 0 ? equinix_metal_reserved_ip_block.ip_pool[0].cidr_notation : ""
}

resource "random_string" "random_k3s_token" {
  length  = 16
  special = false
}

################################################################################
# Control Plane
################################################################################

resource "equinix_metal_device" "control_plane_master" {
  hostname         = "${lower(replace(var.cluster_name, "/\\W|_|\\s/", "-"))}-${var.control_plane_hostnames}-0"
  plan             = var.plan_control_plane
  metro            = var.metal_metro
  operating_system = var.os
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id
  count            = var.k3s_ha ? 1 : 0
  description      = var.cluster_name
  user_data = templatefile("${path.module}/templates/user-data.tftpl", {
    k3s_token       = local.k3s_token,
    API_IP          = local.api_vip,
    global_ip_cidr  = var.global_ip_cidr,
    ip_pool         = local.ip_pool_cidr,
    k3s_version     = var.k3s_version,
    metallb_version = var.metallb_version,
    deploy_demo     = var.deploy_demo,
  node_type = "control-plane-master" })
}

resource "equinix_metal_bgp_session" "control_plane_master" {
  device_id      = equinix_metal_device.control_plane_master[0].id
  address_family = "ipv4"
  count          = var.k3s_ha ? 1 : 0
}

resource "equinix_metal_reserved_ip_block" "api_vip_addr" {
  count       = var.k3s_ha ? 1 : 0
  project_id  = var.metal_project_id
  metro       = var.metal_metro
  type        = "public_ipv4"
  quantity    = 1
  description = "K3s API IP"
}

resource "equinix_metal_device" "control_plane_others" {
  hostname         = format("%s-%d", "${lower(replace(var.cluster_name, "/\\W|_|\\s/", "-"))}-${var.control_plane_hostnames}", count.index + 1)
  plan             = var.plan_control_plane
  metro            = var.metal_metro
  operating_system = var.os
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id
  count            = var.k3s_ha ? 2 : 0
  description      = var.cluster_name
  depends_on       = [equinix_metal_device.control_plane_master]
  user_data = templatefile("${path.module}/templates/user-data.tftpl", {
    k3s_token       = local.k3s_token,
    API_IP          = local.api_vip,
    global_ip_cidr  = "",
    ip_pool         = "",
    k3s_version     = var.k3s_version,
    metallb_version = var.metallb_version,
    deploy_demo     = false,
  node_type = "control-plane" })
}

resource "equinix_metal_bgp_session" "control_plane_second" {
  device_id      = equinix_metal_device.control_plane_others[0].id
  address_family = "ipv4"
  count          = var.k3s_ha ? 1 : 0
}

resource "equinix_metal_bgp_session" "control_plane_third" {
  device_id      = equinix_metal_device.control_plane_others[1].id
  address_family = "ipv4"
  count          = var.k3s_ha ? 1 : 0
}

################################################################################
# IP Pool
################################################################################

resource "equinix_metal_reserved_ip_block" "ip_pool" {
  project_id  = var.metal_project_id
  type        = "public_ipv4"
  quantity    = var.ip_pool_count
  metro       = var.metal_metro
  count       = var.ip_pool_count > 0 ? 1 : 0
  description = "IP Pool to be used for LoadBalancers via MetalLB"
}

################################################################################
# Nodes
################################################################################

resource "equinix_metal_device" "nodes" {
  hostname         = format("%s-%02d", "${lower(replace(var.cluster_name, "/\\W|_|\\s/", "-"))}-${var.node_hostnames}", count.index)
  plan             = var.plan_node
  metro            = var.metal_metro
  operating_system = var.os
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id
  count            = var.node_count
  description      = var.cluster_name
  depends_on       = [equinix_metal_device.control_plane_master]
  user_data = templatefile("${path.module}/templates/user-data.tftpl", {
    k3s_token       = local.k3s_token,
    API_IP          = local.api_vip,
    global_ip_cidr  = "",
    ip_pool         = "",
    k3s_version     = var.k3s_version,
    metallb_version = var.metallb_version,
    deploy_demo     = false,
  node_type = "node" })
}

################################################################################
# All in One
################################################################################

resource "equinix_metal_device" "all_in_one" {
  hostname         = "${lower(replace(var.cluster_name, "/\\W|_|\\s/", "-"))}-${var.control_plane_hostnames}-aio"
  plan             = var.plan_control_plane
  metro            = var.metal_metro
  operating_system = var.os
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id
  count            = var.k3s_ha ? 0 : 1
  description      = var.cluster_name
  user_data = templatefile("${path.module}/templates/user-data.tftpl", {
    k3s_token       = local.k3s_token,
    global_ip_cidr  = var.global_ip_cidr,
    ip_pool         = local.ip_pool_cidr,
    API_IP          = "",
    k3s_version     = var.k3s_version,
    metallb_version = var.metallb_version,
    deploy_demo     = var.deploy_demo,
  node_type = "all-in-one" })
}

# Despite being used or not, enable BGP just in case
resource "equinix_metal_bgp_session" "all_in_one" {
  device_id      = equinix_metal_device.all_in_one[0].id
  address_family = "ipv4"
  count          = var.k3s_ha ? 0 : 1
}
