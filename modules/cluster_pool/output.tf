output "controller_addresses" {
  description = "K3s Controller Address"
  value       = "${packet_device.k3s_primary.network.0.address}"
}

