output "Kubernetes_Cluster_Info" {
  value = "Changes applied, your Anycast IP, ${packet_reserved_ip_block.anycast_ip.address}, is provisioned, and you can validate BGP status here:\n\n\thttps://app.packet.net/projects/${var.project_id}/network/bgp"
}
