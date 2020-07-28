K3s on Packet
==

[![Build Status](https://cloud.drone.io/api/badges/packet-labs/packet-k3s/status.svg)](https://cloud.drone.io/packet-labs/packet-k3s)
[![GitHub release](https://img.shields.io/github/release/packet-labs/terraform-packet-k3s/all.svg?style=flat-square)](https://github.com/packet-labs/terraform-packet-k3s/releases)
[![Slack](https://slack.packet.com/badge.svg)](https://slack.packet.com)
[![Twitter Follow](https://img.shields.io/twitter/follow/packethost.svg?style=social&label=Follow)](https://twitter.com/intent/follow?screen_name=packethost)

This is a [Terraform](https://www.terraform.io/docs/providers/packet/index.html) project for deploying [K3s](https://k3s.io) on [Packet](https://packet.com).

New projects can build on this [Packet K3s Terraform Registry module](https://registry.terraform.io/modules/packet-labs/k3s/packet/) with:

```sh
terraform init --from-module=packet/k3s/packet packet-k3s
```

This project configures your cluster with:

- [MetalLB](https://metallb.universe.tf/) using Packet elastic IPs.
- [Packet CSI](https://github.com/packethost/csi-packet) storage driver.

on ARM devices.

This is intended to allow you to quickly spin-up and down K3s clusters in edge locations. 

Requirements
-

The only required variables are `auth_token` (your [Packet API](https://www.packet.com/developers/api/#) key), your Packet `project_id`, `facility`, and `count` (number of ARM nodes in the cluster, not counting the controller, which is always set to `1`--if you wish to only run the controller, and its local node, set this value to `0`). 

In addition to Terraform, your client machine (where Terraform will be run from) will need [`curl`](https://curl.haxx.se/download.html), and [`jq`](https://stedolan.github.io/jq/download/) available in order for all of the automation to run as expected.

You will need an SSH key associated with this project, or your account. Add the identity path to `ssh_private_key`--this will only be used _locally_ to assist Terraform in completing cluster bootstrapping (needed to retrieve the cluster node-token from the controller node). 

BGP will need to be enabled for your project. 

Clusters
-

<h3>Generating a Cluster Template</h3>

To ensure all your regions have standardized deployments, in your Terraform variables (`TF_VAR_varname` or in `terraform.tfvars`), ensure that you have set `count` (number of nodes per cluster), `plan_primary`, and `plan_node`. This will apply to **all** clusters managed by this project. 


To add new clusters to a cluster pool, add the new facility to the `facilities` map:

```
variable "facilities" {
  type = "map"

  default = {
    newark  = "ewr1"
    narita  = "nrt1"
    sanjose = "sjc1"
  }
}
```

by adding a line such as:
```
...
	chicago = "ord1"
   }
}
```

<h3>Manually defining a Cluster, or adding a new cluster pool</h3>

To create a cluster manually, in `3-cluster-inventory.tf` (this is ignored by git--your initial cluster setup is in `2-clusters.tf`, and is tracked), instantiate a new `cluster_pool` module:

```
module "manual_cluster" {
  source = "./modules/cluster_pool"

  cluster_name         = "manual_cluster"
  node_count           = "${var.node_count}"
  plan_primary         = "${var.plan_primary}"
  plan_node            = "${var.plan_node}"
  facilities           = "${var.facilities}"
  primary_facility     = "${var.primary_facility}"
  auth_token           = "${var.auth_token}"
  project_id           = "${var.project_id}"
  ssh_private_key_path = "${var.ssh_private_key_path}"
  anycast_ip           = "${packet_reserved_ip_block.anycast_ip.address}"
}
```
This creates a single-controller cluster, with `count` number of agent nodes for each `facility` in the `facilities` map.

<h3>Demo Project</h3>

In `example/`, there are files to configure and deploy a demo project that, once your request is received, returns the IP of the cluster serving your request to demonstrate the use of Packet's Global IPv4 addresses to distribute traffic globally to your edge cluster deployments.

To run the project, you can run the `deploy_demo` Ansible project by running the `create_inventory.sh` script to gather your cluster controller IPs into your inventory for Ansible:

```
cd example/
sh create_inventory.sh
cd deploy_demo
ansible-playbook -i inventory.yaml main.yml
```

or manually copy `example/deploy_demo/roles/demo/files/traefik.sh` to your `kubectl` client machine and run manually to deploy Traefik and the application.

