# K3s cluster Terraform module

<!-- TEMPLATE: The following block has been generated by terraform-docs util: https://github.com/terraform-docs/terraform-docs -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_equinix"></a> [equinix](#requirement\_equinix) | >= 1.14.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_equinix"></a> [equinix](#provider\_equinix) | >= 1.14.2 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Modules

No modules.

## Resources

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
| [equinix_metal_reserved_ip_block.ip_pool](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/metal_reserved_ip_block) | resource |
| [random_string.random_k3s_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metal_project_id"></a> [metal\_project\_id](#input\_metal\_project\_id) | Your Equinix Metal Project ID | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name | `string` | `"K3s cluster"` | no |
| <a name="input_control_plane_hostnames"></a> [control\_plane\_hostnames](#input\_control\_plane\_hostnames) | Control plane hostname prefix | `string` | `"cp"` | no |
| <a name="input_custom_k3s_token"></a> [custom\_k3s\_token](#input\_custom\_k3s\_token) | K3s token used for nodes to join the cluster (autogenerated otherwise) | `string` | `null` | no |
| <a name="input_deploy_demo"></a> [deploy\_demo](#input\_deploy\_demo) | Deploys a simple demo using a global IP as ingress and a hello-kubernetes pods | `bool` | `false` | no |
| <a name="input_global_ip_cidr"></a> [global\_ip\_cidr](#input\_global\_ip\_cidr) | Global Anycast IP that will be mapped on all metros via BGP | `string` | `null` | no |
| <a name="input_ip_pool_count"></a> [ip\_pool\_count](#input\_ip\_pool\_count) | Number of public IPv4 per metro to be used as LoadBalancers with MetalLB | `number` | `0` | no |
| <a name="input_k3s_ha"></a> [k3s\_ha](#input\_k3s\_ha) | K3s HA (aka 3 control plane nodes) | `bool` | `false` | no |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | K3s version to be installed. Empty for latest | `string` | `""` | no |
| <a name="input_metallb_version"></a> [metallb\_version](#input\_metallb\_version) | MetalLB version to be installed. Empty for latest | `string` | `""` | no |
| <a name="input_metro"></a> [metro](#input\_metro) | Equinix metro code | `string` | `"FR"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of K3s nodes | `number` | `"0"` | no |
| <a name="input_node_hostnames"></a> [node\_hostnames](#input\_node\_hostnames) | Node hostname prefix | `string` | `"node"` | no |
| <a name="input_os"></a> [os](#input\_os) | Operating system | `string` | `"debian_11"` | no |
| <a name="input_plan_control_plane"></a> [plan\_control\_plane](#input\_plan\_control\_plane) | K3s control plane type/size | `string` | `"c3.small.x86"` | no |
| <a name="input_plan_node"></a> [plan\_node](#input\_plan\_node) | K3s node type/size | `string` | `"c3.small.x86"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_k3s_api_ip"></a> [k3s\_api\_ip](#output\_k3s\_api\_ip) | K3s API IPs |
<!-- END_TF_DOCS -->

## Contributing

If you would like to contribute to this module, see [CONTRIBUTING](CONTRIBUTING.md) page.

## License

Apache License, Version 2.0. See [LICENSE](LICENSE).