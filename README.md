K3s on Packet
==

This is a [Terraform](https://www.terraform.io/docs/providers/packet/index.html) project for deploying [K3s](https://k3s.io) on [Packet](https://packet.com).

This project configures your cluster with:

- [MetalLB](https://metallb.universe.tf/) using Packet elastic IPs.
- [Packet CSI](https://github.com/packethost/csi-packet) storage driver.

on ARM devices.

This is intended to allow you to quickly spin-up and down K3s clusters in edge locations. 

Requirements
-

The only required variables are `auth_token` (your [Packet API](https://www.packet.com/developers/api/#) key), `facility`, and `count_arm` (ARM devices). 

Clusters
-

To create a cluster, in `2-clusters.tf`, create a `cluster_pool` module:

```
module "cluster_nrt1" {
  source = "modules/cluster_pool"

  count                = "${var.count}"
  plan_primary         = "${var.plan_primary}"
  plan_node            = "${var.plan_node}"
  facility             = "nrt1"
  cluster_name         = "${var.cluster_name}"
  auth_token           = "${var.auth_token}"
  project_id           = "${packet_project.k3s_packet.id}"
  packet_network_block = "${packet_reserved_ip_block.kubernetes.cidr_notation}"
}
```

This creates a single-controller cluster, with `count` number of agent nodes in `facility`.
