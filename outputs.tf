output "anycast_ip" {
  value       = try(equinix_metal_reserved_ip_block.global_ip[0].address, null)
  description = "Global IP shared across Metros"
}

output "demo_url" {
  value       = try("http://hellok3s.${equinix_metal_reserved_ip_block.global_ip[0].address}.sslip.io", null)
  description = "URL of the demo application to demonstrate a global IP shared across Metros"
}

output "cluster_details" {
  value = {
    for cluster in var.clusters : cluster.name => {
      api          = module.kube_cluster[cluster.name].kube_api_ip
      ingress      = module.kube_cluster[cluster.name].ingress_ip
      ip_pool_cidr = module.kube_cluster[cluster.name].ip_pool_cidr
      nodes        = module.kube_cluster[cluster.name].nodes_details
    }
  }
  description = "List of Clusters => K8s details"
}

output "rancher_urls" {
  value = {
    for cluster in var.clusters : cluster.name => {
      rancher_url                     = cluster.rancher_flavor != "" ? module.kube_cluster[cluster.name].rancher_address : null
      rancher_initial_password_base64 = cluster.rancher_flavor != "" ? base64encode(module.kube_cluster[cluster.name].rancher_password) : null
    }
    if module.kube_cluster[cluster.name].rancher_address != null
  }
  description = "List of Clusters => Rancher details"
}
