locals {
  token        = coalesce(var.custom_token, random_string.random_token.result)
  rancher_pass = var.custom_rancher_password != null ? coalesce(var.custom_rancher_password, random_string.random_password.result) : null
  api_vip      = var.ha ? equinix_metal_reserved_ip_block.api_vip_addr[0].address : equinix_metal_device.all_in_one[0].network[0].address
  ingress_ip   = var.ip_pool_count > 0 ? equinix_metal_reserved_ip_block.ingress_addr[0].address : ""
  ip_pool_cidr = var.ip_pool_count > 0 ? equinix_metal_reserved_ip_block.ip_pool[0].cidr_notation : ""
}

resource "random_string" "random_token" {
  length  = 16
  special = false
}

resource "random_string" "random_password" {
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
  count            = var.ha ? 1 : 0
  description      = var.cluster_name
  user_data = templatefile("${path.module}/templates/user-data.tftpl", {
    token           = local.token,
    API_IP          = local.api_vip,
    ingress_ip      = local.ingress_ip,
    global_ip_cidr  = var.global_ip_cidr,
    ip_pool         = local.ip_pool_cidr,
    kube_version    = var.kube_version,
    metallb_version = var.metallb_version,
    deploy_demo     = var.deploy_demo,
    rancher_flavor  = var.rancher_flavor,
    rancher_version = var.rancher_version,
    rancher_pass    = local.rancher_pass,
  node_type = "control-plane-master" })
}

resource "equinix_metal_bgp_session" "control_plane_master" {
  device_id      = equinix_metal_device.control_plane_master[0].id
  address_family = "ipv4"
  count          = var.ha ? 1 : 0
}

resource "equinix_metal_reserved_ip_block" "api_vip_addr" {
  count       = var.ha ? 1 : 0
  project_id  = var.metal_project_id
  metro       = var.metal_metro
  type        = "public_ipv4"
  quantity    = 1
  description = "Kubernetes API IP for the ${var.cluster_name} cluster"
}

resource "equinix_metal_reserved_ip_block" "ingress_addr" {
  count       = var.ip_pool_count > 0 ? 1 : 0
  project_id  = var.metal_project_id
  metro       = var.metal_metro
  type        = "public_ipv4"
  quantity    = 1
  description = "Ingress IP for the ${var.cluster_name} cluster"
}

resource "equinix_metal_device" "control_plane_others" {
  hostname         = format("%s-%d", "${lower(replace(var.cluster_name, "/\\W|_|\\s/", "-"))}-${var.control_plane_hostnames}", count.index + 1)
  plan             = var.plan_control_plane
  metro            = var.metal_metro
  operating_system = var.os
  billing_cycle    = "hourly"
  project_id       = var.metal_project_id
  count            = var.ha ? 2 : 0
  description      = var.cluster_name
  depends_on       = [equinix_metal_device.control_plane_master]
  user_data = templatefile("${path.module}/templates/user-data.tftpl", {
    token           = local.token,
    API_IP          = local.api_vip,
    ingress_ip      = local.ingress_ip,
    global_ip_cidr  = "",
    ip_pool         = "",
    kube_version    = var.kube_version,
    metallb_version = var.metallb_version,
    rancher_flavor  = var.rancher_flavor,
    rancher_version = var.rancher_version,
    rancher_pass    = local.rancher_pass,
    deploy_demo     = false,
  node_type = "control-plane" })
}

resource "equinix_metal_bgp_session" "control_plane_second" {
  device_id      = equinix_metal_device.control_plane_others[0].id
  address_family = "ipv4"
  count          = var.ha ? 1 : 0
}

resource "equinix_metal_bgp_session" "control_plane_third" {
  device_id      = equinix_metal_device.control_plane_others[1].id
  address_family = "ipv4"
  count          = var.ha ? 1 : 0
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
  description = "IP Pool to be used for LoadBalancers via MetalLB on the ${var.cluster_name} cluster"
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
    token           = local.token,
    API_IP          = local.api_vip,
    ingress_ip      = local.ingress_ip,
    global_ip_cidr  = "",
    ip_pool         = "",
    kube_version    = var.kube_version,
    metallb_version = var.metallb_version,
    rancher_flavor  = var.rancher_flavor,
    rancher_version = var.rancher_version,
    rancher_pass    = local.rancher_pass,
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
  count            = var.ha ? 0 : 1
  description      = var.cluster_name
  user_data = templatefile("${path.module}/templates/user-data.tftpl", {
    token           = local.token,
    global_ip_cidr  = var.global_ip_cidr,
    ip_pool         = local.ip_pool_cidr,
    API_IP          = "",
    ingress_ip      = local.ingress_ip,
    kube_version    = var.kube_version,
    metallb_version = var.metallb_version,
    deploy_demo     = var.deploy_demo,
    rancher_flavor  = var.rancher_flavor,
    rancher_version = var.rancher_version,
    rancher_pass    = local.rancher_pass,
  node_type = "all-in-one" })
}

# Despite being used or not, enable BGP just in case
resource "equinix_metal_bgp_session" "all_in_one" {
  device_id      = equinix_metal_device.all_in_one[0].id
  address_family = "ipv4"
  count          = var.ha ? 0 : 1
}
