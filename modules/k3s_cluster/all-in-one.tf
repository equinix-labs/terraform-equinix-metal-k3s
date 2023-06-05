resource "equinix_metal_device" "all_in_one" {
  hostname         = "${lower(replace(var.cluster_name, "/\\W|_|\\s/", "-"))}-${var.control_plane_hostnames}-aio"
  plan             = var.plan_control_plane
  metro            = var.metro
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
