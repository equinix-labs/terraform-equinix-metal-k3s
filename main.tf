resource "metal_reserved_ip_block" "anycast_ip" {
  project_id = var.project_id
  type       = "global_ipv4"
  quantity   = 1
  facility   = ""
}
