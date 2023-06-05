resource "equinix_metal_device" "nodes" {
  hostname         = format("%s-%02d", "${lower(replace(var.cluster_name, "/\\W|_|\\s/", "-"))}-${var.node_hostnames}", count.index)
  plan             = var.plan_node
  metro            = var.metro
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
