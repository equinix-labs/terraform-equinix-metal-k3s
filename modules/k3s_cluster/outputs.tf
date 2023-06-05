output "k3s_api_ip" {
  value       = var.k3s_ha ? equinix_metal_reserved_ip_block.api_vip_addr[0].address : equinix_metal_device.all_in_one[0].network[0].address
  description = "K3s API IPs"
}
