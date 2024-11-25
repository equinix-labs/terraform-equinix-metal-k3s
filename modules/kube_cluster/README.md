# K3s/RKE2 Cluster In-line Module

This in-line module deploys the K3s/RKE2 cluster.

## Notes

* Terraform tries to replace all variables within the templated script, so it fails

  As a workaround, an extra dollar symbol ($) has been added to the variables that doesn't need to be replaced by terraform templating.

  See [this](https://discuss.hashicorp.com/t/invalid-value-for-vars-parameter-vars-map-does-not-contain-key-issue/12074/4) and [this](https://github.com/hashicorp/terraform/issues/23384) for more information.

* ServiceLB disabled

  `--disable servicelb` is required for metallb to work
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_equinix"></a> [equinix](#requirement\_equinix) | >= 1.14.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_equinix"></a> [equinix](#provider\_equinix) | >= 1.14.2 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [equinix_metal_bgp_session.all_in_one](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_bgp_session) | resource |
| [equinix_metal_bgp_session.control_plane_master](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_bgp_session) | resource |
| [equinix_metal_bgp_session.control_plane_second](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_bgp_session) | resource |
| [equinix_metal_bgp_session.control_plane_third](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_bgp_session) | resource |
| [equinix_metal_device.all_in_one](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_device) | resource |
| [equinix_metal_device.control_plane_master](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_device) | resource |
| [equinix_metal_device.control_plane_others](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_device) | resource |
| [equinix_metal_device.nodes](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_device) | resource |
| [equinix_metal_reserved_ip_block.api_vip_addr](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_reserved_ip_block) | resource |
| [equinix_metal_reserved_ip_block.ingress_addr](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_reserved_ip_block) | resource |
| [equinix_metal_reserved_ip_block.ip_pool](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_reserved_ip_block) | resource |
| [random_string.random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.random_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metal_metro"></a> [metal\_metro](#input\_metal\_metro) | Equinix Metal Metro | `string` | n/a | yes |
| <a name="input_metal_project_id"></a> [metal\_project\_id](#input\_metal\_project\_id) | Equinix Metal Project ID | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name | `string` | `"Cluster"` | no |
| <a name="input_control_plane_hostnames"></a> [control\_plane\_hostnames](#input\_control\_plane\_hostnames) | Control plane hostname prefix | `string` | `"cp"` | no |
| <a name="input_custom_rancher_password"></a> [custom\_rancher\_password](#input\_custom\_rancher\_password) | Rancher initial password (autogenerated if not provided) | `string` | `null` | no |
| <a name="input_custom_token"></a> [custom\_token](#input\_custom\_token) | Token used for nodes to join the cluster (autogenerated otherwise) | `string` | `null` | no |
| <a name="input_deploy_demo"></a> [deploy\_demo](#input\_deploy\_demo) | Deploys a simple demo using a global IP as ingress and a hello-kubernetes pods | `bool` | `false` | no |
| <a name="input_global_ip_cidr"></a> [global\_ip\_cidr](#input\_global\_ip\_cidr) | Global Anycast IP that will be mapped on all metros via BGP | `string` | `null` | no |
| <a name="input_ha"></a> [ha](#input\_ha) | HA (aka 3 control plane nodes) | `bool` | `false` | no |
| <a name="input_ip_pool_count"></a> [ip\_pool\_count](#input\_ip\_pool\_count) | Number of public IPv4 per metro to be used as LoadBalancers with MetalLB (it needs to be power of 2 between 0 and 256 as required by Equinix Metal) | `number` | `0` | no |
| <a name="input_kube_version"></a> [kube\_version](#input\_kube\_version) | K3s/RKE2 version to be installed. Empty for latest K3s | `string` | `""` | no |
| <a name="input_metallb_version"></a> [metallb\_version](#input\_metallb\_version) | MetalLB version to be installed. Empty for latest | `string` | `""` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of nodes | `number` | `"0"` | no |
| <a name="input_node_hostnames"></a> [node\_hostnames](#input\_node\_hostnames) | Node hostname prefix | `string` | `"node"` | no |
| <a name="input_os"></a> [os](#input\_os) | Operating system | `string` | `"debian_11"` | no |
| <a name="input_plan_control_plane"></a> [plan\_control\_plane](#input\_plan\_control\_plane) | Control plane type/size | `string` | `"c3.small.x86"` | no |
| <a name="input_plan_node"></a> [plan\_node](#input\_plan\_node) | Node type/size | `string` | `"c3.small.x86"` | no |
| <a name="input_rancher_flavor"></a> [rancher\_flavor](#input\_rancher\_flavor) | Rancher flavor to be installed (prime, latest, stable or alpha). Empty to not install it | `string` | `""` | no |
| <a name="input_rancher_version"></a> [rancher\_version](#input\_rancher\_version) | Rancher version to be installed (vX.Y.Z). Empty for latest | `string` | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ingress_ip"></a> [ingress\_ip](#output\_ingress\_ip) | Ingress IP |
| <a name="output_ip_pool_cidr"></a> [ip\_pool\_cidr](#output\_ip\_pool\_cidr) | IP Pool for LoadBalancer SVCs |
| <a name="output_kube_api_ip"></a> [kube\_api\_ip](#output\_kube\_api\_ip) | K8s API IPs |
| <a name="output_nodes_details"></a> [nodes\_details](#output\_nodes\_details) | Nodes external and internal IPs |
| <a name="output_rancher_address"></a> [rancher\_address](#output\_rancher\_address) | Rancher URL |
| <a name="output_rancher_password"></a> [rancher\_password](#output\_rancher\_password) | Rancher initial password |
<!-- END_TF_DOCS -->