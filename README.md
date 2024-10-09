# K3s/RKE2 on Equinix Metal

[![GitHub release](https://img.shields.io/github/release/equinix-labs/terraform-equinix-metal-k3s/all.svg?style=flat-square)](https://github.com/equinix-labs/terraform-equinix-metal-k3s/releases)
![](https://img.shields.io/badge/Stability-Experimental-red.svg)
[![Equinix Community](https://img.shields.io/badge/Equinix%20Community%20-%20%23E91C24?logo=equinixmetal)](https://community.equinix.com)

## Table of content

<details><summary>Table of content</summary><p>

- [K3s/RKE2 on Equinix Metal](#k3srke2-on-equinix-metal)
  - [Table of content](#table-of-content)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Variable requirements](#variable-requirements)
  - [Demo application](#demo-application)
  - [Example scenarios](#example-scenarios)
    - [Single node in default Metro](#single-node-in-default-metro)
    - [Single node in 2 different Metros](#single-node-in-2-different-metros)
    - [1 x All-in-one cluster with Rancher (stable), a custom K3s version \& 1 public IP (+1 for Ingress) + 1 x All-in-one with 1 extra node \& a custom RKE2 version + 1 x HA cluster with 3 nodes \& 4 public IPs. Global IPV4 and demo app deployed](#1-x-all-in-one-cluster-with-rancher-stable-a-custom-k3s-version--1-public-ip-1-for-ingress--1-x-all-in-one-with-1-extra-node--a-custom-rke2-version--1-x-ha-cluster-with-3-nodes--4-public-ips-global-ipv4-and-demo-app-deployed)
  - [Usage](#usage)
  - [Accessing the clusters](#accessing-the-clusters)
  - [Rancher bootstrap and add all clusters to Rancher](#rancher-bootstrap-and-add-all-clusters-to-rancher)
  - [Terraform module documentation](#terraform-module-documentation)
    - [Requirements](#requirements)
    - [Providers](#providers)
    - [Modules](#modules)
    - [Resources](#resources)
    - [Inputs](#inputs)
    - [Outputs](#outputs)
  - [Contributing](#contributing)
  - [License](#license)

</p></details>

## Introduction

This is a [Terraform](hhttps://registry.terraform.io/providers/equinix/metal/latest/docs) project for deploying [K3s](https://k3s.io) (or [RKE2](https://docs.rke2.io/)) on [Equinix Metal](https://metal.equinix.com) intended to allow you to quickly spin-up and down K3s/RKE2 clusters.

[K3s](https://docs.k3s.io/) is a fully compliant and lightweight Kubernetes distribution focused on Edge, IoT, ARM or just for situations where a PhD in K8s clusterology is infeasible. [RKE2](https://docs.rke2.io/) is Rancher’s next-generation Kubernetes distribution, it combines the best-of-both-worlds from the 1.x version of RKE (hereafter referred to as RKE1) anxd K3s. From K3s, it inherits the usability, ease-of-operations, and deployment model. From RKE1, it inherits close alignment with upstream Kubernetes. In places K3s has diverged from upstream Kubernetes in order to optimize for edge deployments, but RKE1 and RKE2 can stay closely aligned with upstream.

> :warning: This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

This terraform project supports a wide variety of scenarios and mostly focused on Edge, such as:

* Single node K3s/RKE2 cluster on a single Equinix Metal Metro.
* HA K3s/RKE2 cluster (3 control plane nodes) using [MetalLB](https://metallb.universe.tf/) + BGP to provide an HA K3s/RKE2 API entrypoint.
* Any number of worker nodes (both for single node or HA scenarios).
* Any number of public IPv4s to be used to expose services to the outside using `LoadBalancer` services via MetalLB.
* Optionally it can deploy Rancher Manager on top of the cluster.
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
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Kubernetes cluster definition | `list of kubernetes cluster objects` | n/a | yes |

> :note: The Equinix Metal Auth Token should be defined in a `provider` block in your own Terraform config. In this project, that is done in `examples/demo_cluster/`, not in the root.  This pattern facilitates [Implicit Provider Inheritance](https://developer.hashicorp.com/terraform/language/modules/develop/providers#implicit-provider-inheritance) and better reuse of Terraform modules.

For more details on the variables, see the [Terraform module documentation](#terraform-module-documentation) section.

The default variables are set to deploy a single node K3s (latest K3s version available) cluster in the FR Metro, using a Equinix Metal's c3.small.x86. You just need to add the cluster name as:

```bash
metal_auth_token = "redacted"
metal_project_id = "redacted"
clusters         = [
  {
    name = "FR DEV Cluster"
  }
]
```

Change each default variable at your own risk, see [Example scenarios](#example-scenarios) and the [kube_cluster module README.md file](modules/kube_cluster/README.md) for more details.

> :warning: The hostnames are created based on the Cluster Name and the `control_plane_hostnames` & `node_hostnames` variables (normalized), beware the lenght of those variables.

You can create a [terraform.tfvars](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files) file with the appropiate content or use the [`TF_VAR_` environment variables](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables).

> :warning: The only OS that has been tested is Debian 11.

## Demo application

If enabled (`deploy_demo = true`), a demo application ([hello-kubernetes](https://github.com/paulbouwer/hello-kubernetes)) will be deployed on all the clusters. An extra [Ingress-NGINX Controller](https://github.com/kubernetes/ingress-nginx) is deployed on each cluster to expose that application and the load will be spreaded among all the clusters. This means that different requests will be routed to different clusters. See [the MetalLB documentation](https://metallb.universe.tf/concepts/bgp/#load-balancing-behavior) for more information about how BGP load balancing works.

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

clusters_output = {
  "cluster_details" = {
    "FR DEV Cluster" = {
      "api" = "147.28.184.239"
      "nodes" = {
        "fr-dev-cluster-cp-aio" = {
          "node_private_ipv4" = "10.25.49.1"
          "node_public_ipv4" = "147.28.184.239"
        }
      }
    }
  }
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

clusters_output = {
  "cluster_details" = {
    "FR DEV Cluster" = {
      "api" = "147.28.184.239"
      "nodes" = {
        "fr-dev-cluster-cp-aio" = {
          "node_private_ipv4" = "10.25.49.1"
          "node_public_ipv4" = "147.28.184.239"
        }
      }
    }
    "SV DEV Cluster" = {
      "api" = "139.178.70.53"
      "nodes" = {
        "sv-dev-cluster-cp-aio" = {
          "node_private_ipv4" = "10.67.31.129"
          "node_public_ipv4" = "139.178.70.53"
        }
      }
    }
  }
}
```

### 1 x All-in-one cluster with Rancher (stable), a custom K3s version & 1 public IP (+1 for Ingress) + 1 x All-in-one with 1 extra node & a custom RKE2 version + 1 x HA cluster with 3 nodes & 4 public IPs. Global IPV4 and demo app deployed

```bash
metal_auth_token = "redacted"
metal_project_id = "redacted"
clusters = [
  {
    name = "FR DEV Cluster"
    rancher_flavor = "stable"
    ip_pool_count = 1
    kube_version = "v1.29.9+k3s1"
  },
  {
    name       = "SV DEV Cluster"
    metro      = "SV"
    node_count = 1
    kube_version = "v1.30.3+rke2r1"
  },
  {
    name          = "SV Production"
    ip_pool_count = 4
    ha        = true
    metro         = "SV"
    node_count    = 3
  }
]

global_ip   = true
deploy_demo = true
```

This will produce something similar to:

```bash
Outputs:

clusters_output = {
  "anycast_ip" = "147.75.40.34"
  "cluster_details" = {
    "FR DEV Cluster" = {
      "api" = "147.28.184.239"
      "ingress" = "147.28.184.119"
      "ip_pool_cidr" = "147.28.184.118/32"
      "nodes" = {
        "fr-dev-cluster-cp-aio" = {
          "node_private_ipv4" = "10.25.49.1"
          "node_public_ipv4" = "147.28.184.239"
        }
      }
    }
    "SV DEV Cluster" = {
      "api" = "139.178.70.53"
      "nodes" = {
        "sv-dev-cluster-cp-aio" = {
          "node_private_ipv4" = "10.67.31.129"
          "node_public_ipv4" = "139.178.70.53"
        }
        "sv-dev-cluster-node-00" = {
          "node_private_ipv4" = "10.67.31.131"
          "node_public_ipv4" = "86.109.11.115"
        }
      }
    }
    "SV Production" = {
      "api" = "86.109.11.239"
      "ingress" = "86.109.11.53"
      "ip_pool_cidr" = "139.178.70.68/30"
      "nodes" = {
        "sv-production-cp-0" = {
          "node_private_ipv4" = "10.67.31.133"
          "node_public_ipv4" = "139.178.70.141"
        }
        "sv-production-cp-1" = {
          "node_private_ipv4" = "10.67.31.137"
          "node_public_ipv4" = "136.144.54.109"
        }
        "sv-production-cp-2" = {
          "node_private_ipv4" = "10.67.31.143"
          "node_public_ipv4" = "139.178.94.11"
        }
        "sv-production-node-00" = {
          "node_private_ipv4" = "10.67.31.141"
          "node_public_ipv4" = "136.144.54.113"
        }
        "sv-production-node-01" = {
          "node_private_ipv4" = "10.67.31.135"
          "node_public_ipv4" = "139.178.70.233"
        }
        "sv-production-node-02" = {
          "node_private_ipv4" = "10.67.31.139"
          "node_public_ipv4" = "136.144.54.111"
        }
      }
    }
  }
  "demo_url" = "http://hellok3s.147.75.40.34.sslip.io"
  "rancher_urls" = {
    "FR DEV Cluster" = {
      "rancher_initial_password_base64" = "Zm9vdmFsdWU="
      "rancher_url" = "https://rancher.147.28.184.119.sslip.io"
    }
  }
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

clusters_output = {
  "cluster_details" = {
    "FR DEV Cluster" = {
      "api" = "147.28.184.239"
      "nodes" = {
        "fr-dev-cluster-cp-aio" = {
          "node_private_ipv4" = "10.25.49.1"
          "node_public_ipv4" = "147.28.184.239"
        }
      }
    }
  }
}
```

## Accessing the clusters

As the SSH key for the project has been injected, the clusters can be accessed as:

```bash
(
OUTPUT=$(terraform output -json)
IFS=$'\n'
for cluster in $(echo ${OUTPUT} | jq -r ".clusters_output.value.cluster_details | keys[]"); do
  FIRSTHOST=$(echo ${OUTPUT} | jq -r "first(.clusters_output.value.cluster_details[\"${cluster}\"].nodes[].node_public_ipv4)")
  echo "=== ${cluster} ==="
  ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${FIRSTHOST} -tt 'bash -l -c "kubectl get nodes -o wide"'
done
)

=== FR DEV Cluster ===
NAME                    STATUS   ROLES                  AGE     VERSION        INTERNAL-IP   EXTERNAL-IP      OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
fr-dev-cluster-cp-aio   Ready    control-plane,master   4m31s   v1.29.9+k3s1   10.25.49.1    147.28.184.239   Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.21-k3s2
=== SV DEV Cluster ===
NAME                     STATUS   ROLES                       AGE     VERSION          INTERNAL-IP    EXTERNAL-IP      OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
sv-dev-cluster-cp-aio    Ready    control-plane,etcd,master   4m3s    v1.30.3+rke2r1   10.67.31.129   139.178.70.53    Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.17-k3s1
sv-dev-cluster-node-00   Ready    <none>                      2m29s   v1.30.3+rke2r1   10.67.31.133   139.178.70.233   Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.17-k3s1
=== SV Production ===
NAME                    STATUS   ROLES                       AGE     VERSION        INTERNAL-IP    EXTERNAL-IP      OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
sv-production-cp-0      Ready    control-plane,etcd,master   2m46s   v1.30.5+k3s1   10.67.31.131   139.178.70.141   Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.21-k3s2
sv-production-cp-1      Ready    control-plane,etcd,master   42s     v1.30.5+k3s1   10.67.31.137   136.144.54.111   Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.21-k3s2
sv-production-cp-2      Ready    control-plane,etcd,master   26s     v1.30.5+k3s1   10.67.31.139   136.144.54.113   Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.21-k3s2
sv-production-node-00   Ready    <none>                      63s     v1.30.5+k3s1   10.67.31.135   136.144.54.109   Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.21-k3s2
sv-production-node-01   Ready    <none>                      59s     v1.30.5+k3s1   10.67.31.141   139.178.94.11    Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.21-k3s2
sv-production-node-02   Ready    <none>                      57s     v1.30.5+k3s1   10.67.31.143   139.178.94.19    Debian GNU/Linux 11 (bullseye)   5.10.0-32-amd64   containerd://1.7.21-k3s2
```

To access from outside, the kubeconfig file can be copied to any host and replace the `server` field with the IP of the kubernetes API:

```bash
(
OUTPUT=$(terraform output -json)
IFS=$'\n'
for cluster in $(echo ${OUTPUT} | jq -r ".clusters_output.value.cluster_details | keys[]"); do
  FIRSTHOST=$(echo ${OUTPUT} | jq -r "first(.clusters_output.value.cluster_details[\"${cluster}\"].nodes[].node_public_ipv4)")
  API=$(echo ${OUTPUT} | jq -r ".clusters_output.value.cluster_details[\"${cluster}\"].api")
  export KUBECONFIG="./$(echo ${cluster}| tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]/-/g' | sed 's/ /-/g' | sed 's/^-*\|-*$/''/g')-kubeconfig"
  scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${FIRSTHOST}:/root/.kube/config ${KUBECONFIG}
  sed -i "s/127.0.0.1/${API}/g" ${KUBECONFIG}
  chmod 600 ${KUBECONFIG}
  echo "=== ${cluster} ==="
  kubectl get nodes
done
)

=== FR DEV Cluster ===
NAME                    STATUS   ROLES                  AGE   VERSION
fr-dev-cluster-cp-aio   Ready    control-plane,master   10m   v1.29.9+k3s1
=== SV DEV Cluster ===
NAME                     STATUS   ROLES                       AGE     VERSION
sv-dev-cluster-cp-aio    Ready    control-plane,etcd,master   10m     v1.30.3+rke2r1
sv-dev-cluster-node-00   Ready    <none>                      8m43s   v1.30.3+rke2r1
=== SV Production ===
NAME                    STATUS   ROLES                       AGE     VERSION
sv-production-cp-0      Ready    control-plane,etcd,master   9m      v1.30.5+k3s1
sv-production-cp-1      Ready    control-plane,etcd,master   6m56s   v1.30.5+k3s1
sv-production-cp-2      Ready    control-plane,etcd,master   6m40s   v1.30.5+k3s1
sv-production-node-00   Ready    <none>                      7m17s   v1.30.5+k3s1
sv-production-node-01   Ready    <none>                      7m13s   v1.30.5+k3s1
sv-production-node-02   Ready    <none>                      7m11s   v1.30.5+k3s1
```

> :warning: OSX sed is different, it needs to be used as `sed -i "" "s/127.0.0.1/${API}/g" ${KUBECONFIG}` instead.

```bash
(
OUTPUT=$(terraform output -json)
IFS=$'\n'
for cluster in $(echo ${OUTPUT} | jq -r ".clusters_output.value.cluster_details | keys[]"); do
  FIRSTHOST=$(echo ${OUTPUT} | jq -r "first(.clusters_output.value.cluster_details[\"${cluster}\"].nodes[].node_public_ipv4)")
  API=$(echo ${OUTPUT} | jq -r ".clusters_output.value.cluster_details[\"${cluster}\"].api")
  export KUBECONFIG="./$(echo ${cluster}| tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]/-/g' | sed 's/ /-/g' | sed 's/^-*\|-*$/''/g')-kubeconfig"
  scp -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${FIRSTHOST}:/root/.kube/config ${KUBECONFIG}
  sed -i "" "s/127.0.0.1/${API}/g" ${KUBECONFIG}
  chmod 600 ${KUBECONFIG}
  echo "=== ${cluster} ==="
  kubectl get nodes
done
)

=== FR DEV Cluster ===
NAME                    STATUS   ROLES                  AGE   VERSION
fr-dev-cluster-cp-aio   Ready    control-plane,master   10m   v1.29.9+k3s1
=== SV DEV Cluster ===
NAME                     STATUS   ROLES                       AGE     VERSION
sv-dev-cluster-cp-aio    Ready    control-plane,etcd,master   10m     v1.30.3+rke2r1
sv-dev-cluster-node-00   Ready    <none>                      8m43s   v1.30.3+rke2r1
=== SV Production ===
NAME                    STATUS   ROLES                       AGE     VERSION
sv-production-cp-0      Ready    control-plane,etcd,master   9m      v1.30.5+k3s1
sv-production-cp-1      Ready    control-plane,etcd,master   6m56s   v1.30.5+k3s1
sv-production-cp-2      Ready    control-plane,etcd,master   6m40s   v1.30.5+k3s1
sv-production-node-00   Ready    <none>                      7m17s   v1.30.5+k3s1
sv-production-node-01   Ready    <none>                      7m13s   v1.30.5+k3s1
sv-production-node-02   Ready    <none>                      7m11s   v1.30.5+k3s1
```

## Rancher bootstrap and add all clusters to Rancher

There is a helper script [clusters-to-rancher.sh](./examples/demo_cluster/clusters-to-rancher.sh) that will perform the
[Rancher first login process](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/authentication-permissions-and-global-configuration#first-log-in)
automatically based on the Terraform output.

The script also imports all the other clusters where rancher wasn't deployed.

It only requires the admin password (>=12 characters) that Rancher will use moving forward:

```bash
./clusters-to-rancher.sh -p <finalrancherpassword>
```

![Awesome Rancher screenshot](./rancher-clusters-imported.png?raw=true "Clusters imported")

## Terraform module documentation

<!-- use "terraform-docs markdown table --output-file README.md --output-mode inject --indent 3 ./" to generate this fancy table -->
<!-- TEMPLATE: The following block has been generated by terraform-docs util: https://github.com/terraform-docs/terraform-docs -->
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_equinix"></a> [equinix](#requirement\_equinix) | >= 1.14.2 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_equinix"></a> [equinix](#provider\_equinix) | >= 1.14.2 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kube_cluster"></a> [kube\_cluster](#module\_kube\_cluster) | ./modules/kube_cluster | n/a |

### Resources

| Name | Type |
|------|------|
| [equinix_metal_reserved_ip_block.global_ip](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_reserved_ip_block) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metal_project_id"></a> [metal\_project\_id](#input\_metal\_project\_id) | Equinix Metal Project ID | `string` | n/a | yes |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Cluster definition | <pre>list(object({<br/>    name                    = optional(string, "Demo cluster")<br/>    metro                   = optional(string, "FR")<br/>    plan_control_plane      = optional(string, "c3.small.x86")<br/>    plan_node               = optional(string, "c3.small.x86")<br/>    node_count              = optional(number, 0)<br/>    ha                      = optional(bool, false)<br/>    os                      = optional(string, "debian_11")<br/>    control_plane_hostnames = optional(string, "cp")<br/>    node_hostnames          = optional(string, "node")<br/>    custom_token            = optional(string, "")<br/>    ip_pool_count           = optional(number, 0)<br/>    kube_version            = optional(string, "")<br/>    metallb_version         = optional(string, "")<br/>    rancher_flavor          = optional(string, "")<br/>    rancher_version         = optional(string, "")<br/>    custom_rancher_password = optional(string, "")<br/>  }))</pre> | <pre>[<br/>  {}<br/>]</pre> | no |
| <a name="input_deploy_demo"></a> [deploy\_demo](#input\_deploy\_demo) | Deploys a simple demo using a global IP as ingress and a hello-kubernetes pods | `bool` | `false` | no |
| <a name="input_global_ip"></a> [global\_ip](#input\_global\_ip) | Enables a global anycast IPv4 that will be shared for all clusters in all metros | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_anycast_ip"></a> [anycast\_ip](#output\_anycast\_ip) | Global IP shared across Metros |
| <a name="output_cluster_details"></a> [cluster\_details](#output\_cluster\_details) | List of Clusters => K8s details |
| <a name="output_demo_url"></a> [demo\_url](#output\_demo\_url) | URL of the demo application to demonstrate a global IP shared across Metros |
| <a name="output_rancher_urls"></a> [rancher\_urls](#output\_rancher\_urls) | List of Clusters => Rancher details |
<!-- END_TF_DOCS -->

## Contributing

If you would like to contribute to this module, see [CONTRIBUTING](CONTRIBUTING.md) page.

## License

Apache License, Version 2.0. See [LICENSE](LICENSE).
