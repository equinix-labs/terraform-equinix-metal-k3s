output "anycast_ip" {
  value       = try(equinix_metal_reserved_ip_block.global_ip[0].address, null)
  description = "Global IP shared across Metros"
}

output "demo_url" {
  value       = try("http://hellok3s.${equinix_metal_reserved_ip_block.global_ip[0].address}.sslip.io", null)
  description = "URL of the demo application to demonstrate a global IP shared across Metros"
}

output "k3s_api" {
  value = {
    for cluster in var.clusters : cluster.name => module.k3s_cluster[cluster.name].k3s_api_ip
  }
  description = "List of Clusters => K3s APIs"
}
