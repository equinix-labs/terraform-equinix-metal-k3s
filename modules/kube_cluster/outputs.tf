output "kube_api_ip" {
  value       = local.api_vip
  description = "K8s API IPs"
}

output "rancher_address" {
  value       = var.rancher_flavor != "" ? "https://rancher.${local.ingress_ip}.sslip.io" : null
  description = "Rancher URL"
}

output "rancher_password" {
  value       = var.rancher_flavor != "" ? local.rancher_pass : null
  description = "Rancher initial password"
}

output "ingress_ip" {
  value       = var.ip_pool_count > 0 ? local.ingress_ip : null
  description = "Ingress IP"
}

output "ip_pool_cidr" {
  value       = var.ip_pool_count > 0 ? local.ip_pool_cidr : null
  description = "IP Pool for LoadBalancer SVCs"
}

output "nodes_details" {
  value = {
    for node in flatten([equinix_metal_device.control_plane_master, equinix_metal_device.control_plane_others, equinix_metal_device.nodes, equinix_metal_device.all_in_one]) : node.hostname => {
      node_private_ipv4 = node.access_private_ipv4
      node_public_ipv4  = node.access_public_ipv4
    }
  }
  description = "Nodes external and internal IPs"
}
