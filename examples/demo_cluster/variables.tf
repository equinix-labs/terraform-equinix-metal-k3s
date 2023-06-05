variable "metal_auth_token" {
  type        = string
  sensitive   = true
  description = "Your Equinix Metal API key"
}

variable "metal_project_id" {
  type        = string
  description = "Your Equinix Metal Project ID"
}

variable "global_ip" {
  type        = bool
  description = "Enables a global anycast IPv4 that will be shared for all clusters in all metros"
  default     = true
}

variable "deploy_demo" {
  type        = bool
  description = "Deploys a simple demo using a global IP as ingress and a hello-kubernetes pods"
  default     = true
}

variable "clusters" {
  description = "K3s cluster definition"
  type = list(object({
    name                    = optional(string, "K3s demo cluster")
    metro                   = optional(string, "FR")
    plan_control_plane      = optional(string, "c3.small.x86")
    plan_node               = optional(string, "c3.small.x86")
    node_count              = optional(number, 0)
    k3s_ha                  = optional(bool, false)
    os                      = optional(string, "debian_11")
    control_plane_hostnames = optional(string, "k3s-cp")
    node_hostnames          = optional(string, "k3s-node")
    custom_k3s_token        = optional(string, "")
    ip_pool_count           = optional(number, 0)
    k3s_version             = optional(string, "")
    metallb_version         = optional(string, "")
  }))
  default = [{}]
}
