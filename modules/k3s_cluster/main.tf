locals {
  k3s_token    = coalesce(var.custom_k3s_token, random_string.random_k3s_token.result)
  api_vip      = var.k3s_ha ? equinix_metal_reserved_ip_block.api_vip_addr[0].address : equinix_metal_device.all_in_one[0].network[0].address
  ip_pool_cidr = var.ip_pool_count > 0 ? equinix_metal_reserved_ip_block.ip_pool[0].cidr_notation : ""
}

resource "random_string" "random_k3s_token" {
  length  = 16
  special = false
}
