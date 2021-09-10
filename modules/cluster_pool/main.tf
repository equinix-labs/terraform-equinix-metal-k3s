resource "metal_reserved_ip_block" "metal-k3s" {
  project_id = var.project_id
  for_each   = var.facilities
  facility   = each.value
  quantity   = 2
}

data "template_file" "controller" {
  template = file("${path.module}/controller.tpl")
  for_each = var.facilities
  vars = {
    metal_network_cidr = metal_reserved_ip_block.metal-k3s[each.key].cidr_notation
    metal_auth_token   = var.auth_token
    metal_project_id   = var.project_id
    anycast_ip         = var.anycast_ip
  }
}

resource "metal_device" "k3s_primary" {
  for_each         = var.facilities
  hostname         = "${var.cluster_name}-controller-${each.value}"
  operating_system = "ubuntu_20_04"
  plan             = var.plan_primary
  facilities       = [var.facilities[each.key]]
  user_data        = data.template_file.controller[each.key].rendered

  provisioner "local-exec" {
    command = "/usr/bin/scp -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null scripts/create_bird_conf.sh root@${self.access_public_ipv4}:/root/create_bird_conf.sh"
  }

  billing_cycle = "hourly"
  project_id    = var.project_id
}

resource "metal_bgp_session" "test" {
  for_each       = var.facilities
  device_id      = metal_device.k3s_primary[each.key].id
  address_family = "ipv4"
}

resource "metal_ip_attachment" "kubernetes_lb_block" {
  for_each      = var.facilities
  device_id     = metal_device.k3s_primary[each.key].id
  cidr_notation = metal_reserved_ip_block.metal-k3s[each.key].cidr_notation
}

data "template_file" "node" {
  template = file("${path.module}/node.tpl")
  for_each = var.facilities
  vars = {
    primary_node_ip = metal_device.k3s_primary[each.key].network.0.address
  }
}

resource "metal_device" "worker_node" {
  for_each         = var.facilities
  hostname         = "${var.cluster_name}-worker-${each.value}"
  operating_system = "ubuntu_20_04"
  plan             = var.plan_node
  facilities       = [var.facilities[each.key]]
  user_data        = data.template_file.node[each.key].rendered

  provisioner "local-exec" {
    command = "/usr/bin/scp -3 -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@${metal_device.k3s_primary[each.key].network.0.address}:/var/lib/rancher/k3s/server/node-token root@${self.access_public_ipv4}:node-token"
  }

  billing_cycle = "hourly"
  project_id    = var.project_id
}
