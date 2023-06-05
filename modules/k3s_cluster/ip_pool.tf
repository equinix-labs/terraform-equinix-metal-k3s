resource "equinix_metal_reserved_ip_block" "ip_pool" {
  project_id  = var.metal_project_id
  type        = "public_ipv4"
  quantity    = var.ip_pool_count
  metro       = var.metro
  count       = var.ip_pool_count > 0 ? 1 : 0
  description = "IP Pool to be used for LoadBalancers via MetalLB"
}
