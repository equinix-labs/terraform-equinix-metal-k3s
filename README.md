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

The only required variables are `auth_token` (your [Packet API](https://www.packet.com/developers/api/#) key), your Packet `project_id`, `facility`, and `count` (number of ARM nodes in the cluster, not counting the controller, which is always set to `1`--if you wish to only run the controller, and its local node, set this value to `0`). 

In addition to Terraform, your client machine (where Terraform will be run from) will need [`curl`](https://curl.haxx.se/download.html), and [`jq`](https://stedolan.github.io/jq/download/) available in order for all of the automation to run as expected.

You will need an SSH key associated with this project, or your account. Add the identity path to `ssh_private_key`--this will only be used _locally_ to assist Terraform in completing cluster bootstrapping (needed to retrieve the cluster node-token from the controller node). 

Clusters
-

<h3>Generating a Cluster Template</h3>

To ensure all your regions have standardized deployments, in your Terraform variables (`TF_VAR_varname` or in `terraform.tfvars`), ensure that you have set `count` (number of nodes per cluster), `plan_primary`, and `plan_node`. This will apply to **all** clusters managed by this project. 

Using the `Makefile`, you can quickly add a new cluster definition using:

```bash
make facility="ewr1" cluster_id="control" define-cluster
```

and then apply your new cluster module (if you do not wish to apply any other outstanding state changes via `terraform apply`):

```
make cluster_name="cluster_control_ewr1" apply-cluster
```
where `cluster_name` is the module name for that cluster in `2-clusters.tf`, if you wish to review this manually before applying. This will follow the format `cluster_$cluster-id_$facility`. 

<h3>Manually defining a Cluster</h3>

To create a cluster manually, in `2-clusters.tf`, instantiate a new `cluster_pool` module:

```
module "cluster_nrt1" {
  source = "modules/cluster_pool"

  cluster_name         = "your_cluster_name"
  count                = "${var.count}"
  plan_primary         = "${var.plan_primary}"
  plan_node            = "${var.plan_node}"
  facility             = "nrt1"
  auth_token           = "${var.auth_token}"
  project_id           = "${var.project_id}"
}
```
This creates a single-controller cluster, with `count` number of agent nodes in `facility`.
