# K3s on Equinix Metal

[![GitHub release](https://img.shields.io/github/release/equinix-labs/terraform-equinix-metal-k3s/all.svg?style=flat-square)](https://github.com/equinix-labs/terraform-equinix-metal-k3s/releases)
![](https://img.shields.io/badge/Stability-Experimental-red.svg)
[![Equinix Community](https://img.shields.io/badge/Equinix%20Community%20-%20%23E91C24?logo=equinixmetal)](https://community.equinix.com)

## Table of content

<details><summary>Table of content</summary><p>

  * [Introduction](#introduction)
  * [Prerequisites](#prerequisites)
  * [Variable requirements](#variable-requirements)
  * [Demo application](#demo-application)
  * [Notes](#notes)
  * [Example scenarios](#example-scenarios)
    * [Single node in default Metro](#single-node-in-default-metros)
    * [Single node in 2 different Metros](#single-node-in-2-different-metros)
    * [1 x HA cluster with 3 nodes & 4 public IPs + 2 x Single Node cluster (same Metro), a Global IPV4 and the demo app deployed](#1-x-ha-cluster-with-3-nodes--4-public-ips--2-x-single-node-cluster-same-metro-a-global-ipv4-and-the-demo-app-deployed)
  * [Usage](#usage)
  * [Accessing the clusters](#accessing-the-clusters)
  * [Terraform module documentation](#terraform-module-documentation)
    * [Requirements](#requirements-1)
    * [Providers](#providers)
    * [Modules](#modules)
    * [Resources](#resources)
    * [Inputs](#inputs)
    * [Outputs](#outputs)
  * [Contributing](#contributing)
  * [License](#license)

</p></details>

## Introduction

This is a [Terraform](hhttps://registry.terraform.io/providers/equinix/metal/latest/docs) project for deploying [K3s](https://k3s.io) on [Equinix Metal](https://metal.equinix.com) intended to allow you to quickly spin-up and down K3s clusters.

[K3s](https://docs.k3s.io/) is a fully compliant and lightweight Kubernetes distribution focused on Edge, IoT, ARM or just for situations where a PhD in K8s clusterology is infeasible.

> :warning: This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

This terraform project supports a wide variety of scenarios and mostly focused on Edge, such as:

* Single node K3s cluster on a single Equinix Metal Metro.
* HA K3s cluster (3 control plane nodes) using BGP to provide an HA K3s API entrypoint.
* Any number of worker nodes (both for single node or HA scenarios).
* Any number of public IPv4s to be used to expose services to the outside using `LoadBalancer` services via [MetalLB](https://metallb.universe.tf/) (deployed automatically).
* All those previous scenarios but deploying multiple clusters on multiple Equinix Metal metros.
* A Global IPv4 that is shared in all cluster among all Equnix Metal Metros and can be used to expose an example application to demonstrate load balancing between different Equinix Metal Metros.

More on that later.

## Prerequisites

* An [Equinix Metal account](https://deploy.equinix.com/get-started/)
  <details><summary>Show more details</summary><p>
  An Equinix Metal account needs to be created. You can sign up for free (credit card required).
  </p></details>
* An [Equinix Metal project](https://deploy.equinix.com/developers/docs/metal/accounts/projects/)
  <details><summary>Show more details</summary><p>
  Equinix Metal is organized in Projects. They can be created either via the Web UI, via the CLI or the API. Check the above link for instructions on how to create it.
  </p></details>
* An [Equinx Metal API Key](https://deploy.equinix.com/developers/docs/metal/accounts/api-keys/)
  <details><summary>Show more details</summary><p>
  In order to be able to interact with the Equinix Metal API, an API Key is needed. Check the above link for instructions on how to get it.
  For this project to work, the API Key requires write permissions.
  </p></details>
* [BGP](https://deploy.equinix.com/developers/docs/metal/bgp/local-bgp/) enabled in the project.
  <details><summary>Show more details</summary><p>
  Equinix Metal supports Local BGP for advertising routes to your Equinix Metal servers in a local environment, and this will be used to provide a single entrypoint for the K3s API in HA deployments as well as to provide `LoadBalancer` services using MetalLB. Check the above link for instructions on how to enable it.
  </p></details>
* An [SSH Key](https://deploy.equinix.com/developers/docs/metal/accounts/ssh-keys/) configured.
  <details><summary>Show more details</summary><p>
  Having a SSH in your account or project makes the provision procedure to inject it automatically in the host being provisioned, so you can ssh into it. They can be created either via the Web UI, via the CLI or the API, check the above link for instructions on how to get it.
  </p></details>
* [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
  <details><summary>Show more details</summary><p>
  Terraform is just a single binary. Visit their download page, choose your operating system, make the binary executable, and move it into your path.
  </p></details>
* [git](https://git-scm.com/) to download the content of this repository

> :warning: Before creating the assets, verify there is enough amount of servers in the chosen Metros by visiting the [Capacity Dashboard](https://deploy.equinix.com/developers/capacity-dashboard/). See more about the inventory and capacity [in the official documentation](https://deploy.equinix.com/developers/docs/metal/locations/capacity/)

## Variable requirements

There is a lot of flexibility in the module to allow customization of the different scenarios. There can be as many cluster with different topologies as wanted but mainly, as defined in [examples/demo_cluster](examples/demo_cluster/README.md):

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metal_auth_token"></a> [metal\_auth\_token](#input\_metal\_auth\_token) | Your Equinix Metal API key | `string` | n/a | yes |
| <a name="input_metal_project_id"></a> [metal\_project\_id](#input\_metal\_project\_id) | Your Equinix Metal Project ID | `string` | n/a | yes |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | K3s cluster definition | `list of K3s cluster objects` | n/a | yes |

> :note: The Equinix Metal Auth Token should be defined in a `provider` block in your own Terraform config. In this project, that is done in `examples/demo_cluster/`, not in the root.  This pattern facilitates [Implicit Provider Inheritance](https://developer.hashicorp.com/terraform/language/modules/develop/providers#implicit-provider-inheritance) and better reuse of Terraform modules.

For more details on the variables, see the [Terraform module documentation](#terraform-module-documentation) section.

The default variables are set to deploy a single node K3s cluster in the FR Metro, using a Equinix Metal's c3.small.x86. You just need to add the cluster name as:

```bash
metal_auth_token = "redacted"
metal_project_id = "redacted"
clusters         = [
  {
    name = "FR DEV Cluster"
  }
]
```

Change each default variable at your own risk, see [Example scenarios](#example-scenarios) and the [K3s module README.md file](modules/k3s_cluster/README.md) for more details.

> :warning: The hostnames are created based on the Cluster Name and the `control_plane_hostnames` & `node_hostnames` variables (normalized), beware the lenght of those variables.

You can create a [terraform.tfvars](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files) file with the appropiate content or use the [`TF_VAR_` environment variables](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables).

> :warning: The only OS that has been tested is Debian 11.

## Demo application

If enabled (`deploy_demo = true`), a demo application ([hello-kubernetes](https://github.com/paulbouwer/hello-kubernetes)) will be deployed on all the clusters. The Global IPv4 will be used by the [K3s Traefik Ingress Controller](https://docs.k3s.io/networking#traefik-ingress-controller) to expose that application and the load will be spreaded among all the clusters. This means that different requests will be routed to different clusters. See [the MetalLB documentation](https://metallb.universe.tf/concepts/bgp/#load-balancing-behavior) for more information about how BGP load balancing works.

## Example scenarios

### Single node in default Metro

```bash
metal_auth_token = "redacted"
metal_project_id = "redacted"
clusters         = [
  {
    name = "FR DEV Cluster"
  }
]
```

This will produce something similar to:

```bash
Outputs:

k3s_api = {
  "FR DEV Cluster" = "145.40.94.83"
}
```

### Single node in 2 different Metros

```bash
metal_auth_token = "redacted"
metal_project_id = "redacted"
clusters         = [
  {
    name = "FR DEV Cluster"
  },
  {
    name = "SV DEV Cluster"
    metro = "SV"
  }
]
```

This will produce something similar to:

```bash
Outputs:

k3s_api = {
  "FR DEV Cluster" = "145.40.94.83",
  "SV DEV Cluster" = "86.109.11.205"
}
```

### 1 x HA cluster with 3 nodes & 4 public IPs + 2 x Single Node cluster (same Metro), a Global IPV4 and the demo app deployed

```bash
metal_auth_token = "redacted"
metal_project_id = "redacted"
clusters = [{
  name = "SV Production"
  ip_pool_count = 4
  k3s_ha = true
  metro = "SV"
  node_count = 3
},
{
  name = "FR Dev 1"
  metro = "FR"
},
{
  name = "FR Dev 2"
  metro = "FR"
}
]

global_ip        = true
deploy_demo      = true
```

This will produce something similar to:

```bash
Outputs:

anycast_ip = "147.75.40.52"
demo_url   = "http://hellok3s.147.75.40.52.sslip.io"
k3s_api = {
  "FR Dev 1" = "145.40.94.83",
  "FR Dev 2" = "147.75.192.250",
  "SV Production" = "86.109.11.205"
}
```

## Usage

* Download the repository:

```bash
git clone https://github.com/equinix-labs/terraform-equinix-metal-k3s.git
cd terraform-equinix-metal-k3s/examples/demo_cluster
```

* Initialize terraform:

```bash
terraform init -upgrade
```

* Optionally, configure a proper backend to [store the Terraform state file](https://spacelift.io/blog/terraform-state)

* Modify your variables. Depending on the scenario, some variables are needed and some others are optional but let you customize the scenario as wanted.

* Review the deployment before submitting it with `terraform plan` (or using environment variables) as:

```bash
terraform plan -var-file="foobar.tfvars"
```

* Deploy it

```bash
terraform apply -var-file="foobar.tfvars" --auto-approve
```

* Profit!

The output will show the required IPs or hostnames to use the clusters:

```bash
...
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

k3s_api = {
  "FR example" = "145.40.94.83"
}
```

## Accessing the clusters

As the SSH key for the project has been injected, the clusters can be accessed as:

```bash
(
MODULENAME="demo_cluster"
IFS=$'\n'
for cluster in $(terraform output -json | jq -r ".${MODULENAME}.value.k3s_api | keys[]"); do
  IP=$(terraform output -json | jq -r ".${MODULENAME}.value.k3s_api[\"${cluster}\"]")
  ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${IP} kubectl get nodes
done
)

NAME         STATUS   ROLES                  AGE   VERSION
ny-k3s-aio   Ready    control-plane,master   9m35s v1.26.5+k3s1
NAME         STATUS   ROLES                  AGE   VERSION
sv-k3s-aio   Ready    control-plane,master   10m   v1.26.5+k3s
```

To access from outside, the K3s kubeconfig file can be copied to any host and replace the `server` field with the IP of the K3s API:

```bash
(
MODULENAME="demo_cluster"
IFS=$'\n'
for cluster in $(terraform output -json | jq -r ".${MODULENAME}.value.k3s_api | keys[]"); do
  IP=$(terraform output -json | jq -r ".${MODULENAME}.value.k3s_api[\"${cluster}\"]")
  export KUBECONFIG="./$(echo ${cluster}| tr -c -s '[:alnum:]' '-')-kubeconfig"
  scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${IP}:/etc/rancher/k3s/k3s.yaml ${KUBECONFIG}
  sed -i "s/127.0.0.1/${IP}/g" ${KUBECONFIG}
  chmod 600 ${KUBECONFIG}
  kubectl get nodes
done
)

NAME         STATUS   ROLES                  AGE     VERSION
ny-k3s-aio   Ready    control-plane,master   8m41s   v1.26.5+k3s1
NAME         STATUS   ROLES                  AGE     VERSION
sv-k3s-aio   Ready    control-plane,master   9m20s   v1.26.5+k3s1
```

> :warning: OSX sed is different, it needs to be used as `sed -i "" "s/127.0.0.1/${IP}/g" ${KUBECONFIG}` instead.

```bash
(
MODULENAME="demo_cluster"
IFS=$'\n'
for cluster in $(terraform output -json | jq -r ".${MODULENAME}.value.k3s_api | keys[]"); do
  IP=$(terraform output -json | jq -r ".${MODULENAME}.value.k3s_api[\"${cluster}\"]")
  export KUBECONFIG="./$(echo ${cluster}| tr -c -s '[:alnum:]' '-')-kubeconfig"
  scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${IP}:/etc/rancher/k3s/k3s.yaml ${KUBECONFIG}
  sed -i "" "s/127.0.0.1/${IP}/g" ${KUBECONFIG}
  chmod 600 ${KUBECONFIG}
  kubectl get nodes
done
)

NAME         STATUS   ROLES                  AGE     VERSION
ny-k3s-aio   Ready    control-plane,master   8m41s   v1.26.5+k3s1
NAME         STATUS   ROLES                  AGE     VERSION
sv-k3s-aio   Ready    control-plane,master   9m20s   v1.26.5+k3s1
```

## Terraform module documentation

<!-- TEMPLATE: The following block has been generated by terraform-docs util: https://github.com/terraform-docs/terraform-docs -->
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_equinix"></a> [equinix](#requirement\_equinix) | >= 1.14.2 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_equinix"></a> [equinix](#provider\_equinix) | >= 1.14.2 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_k3s_cluster"></a> [k3s\_cluster](#module\_k3s\_cluster) | ./modules/k3s_cluster | n/a |

### Resources

| Name | Type |
|------|------|
| [equinix_metal_reserved_ip_block.global_ip](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_reserved_ip_block) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metal_project_id"></a> [metal\_project\_id](#input\_metal\_project\_id) | Equinix Metal Project ID | `string` | n/a | yes |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | K3s cluster definition | <pre>list(object({<br>    name                    = optional(string, "K3s demo cluster")<br>    metro                   = optional(string, "FR")<br>    plan_control_plane      = optional(string, "c3.small.x86")<br>    plan_node               = optional(string, "c3.small.x86")<br>    node_count              = optional(number, 0)<br>    k3s_ha                  = optional(bool, false)<br>    os                      = optional(string, "debian_11")<br>    control_plane_hostnames = optional(string, "k3s-cp")<br>    node_hostnames          = optional(string, "k3s-node")<br>    custom_k3s_token        = optional(string, "")<br>    ip_pool_count           = optional(number, 0)<br>    k3s_version             = optional(string, "")<br>    metallb_version         = optional(string, "")<br>  }))</pre> | <pre>[<br>  {}<br>]</pre> | no |
| <a name="input_deploy_demo"></a> [deploy\_demo](#input\_deploy\_demo) | Deploys a simple demo using a global IP as ingress and a hello-kubernetes pods | `bool` | `false` | no |
| <a name="input_global_ip"></a> [global\_ip](#input\_global\_ip) | Enables a global anycast IPv4 that will be shared for all clusters in all metros | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_anycast_ip"></a> [anycast\_ip](#output\_anycast\_ip) | Global IP shared across Metros |
| <a name="output_demo_url"></a> [demo\_url](#output\_demo\_url) | URL of the demo application to demonstrate a global IP shared across Metros |
| <a name="output_k3s_api"></a> [k3s\_api](#output\_k3s\_api) | List of Clusters => K3s APIs |
<!-- END_TF_DOCS -->

## Contributing

If you would like to contribute to this module, see [CONTRIBUTING](CONTRIBUTING.md) page.

## License

Apache License, Version 2.0. See [LICENSE](LICENSE).
