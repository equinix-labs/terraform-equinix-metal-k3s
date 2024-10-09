variable "metal_project_id" {
  type        = string
  description = "Equinix Metal Project ID"
}

variable "global_ip" {
  type        = bool
  description = "Enables a global anycast IPv4 that will be shared for all clusters in all metros"
  default     = false
}

variable "deploy_demo" {
  type        = bool
  description = "Deploys a simple demo using a global IP as ingress and a hello-kubernetes pods"
  default     = false
  validation {
    condition     = !var.deploy_demo || var.global_ip
    error_message = "When deploy_demo is true, global_ip must be true as well."
  }
}

variable "clusters" {
  description = "Cluster definition"
  type = list(object({
    name                    = optional(string, "Demo cluster")
    metro                   = optional(string, "FR")
    plan_control_plane      = optional(string, "c3.small.x86")
    plan_node               = optional(string, "c3.small.x86")
    node_count              = optional(number, 0)
    ha                      = optional(bool, false)
    os                      = optional(string, "debian_11")
    control_plane_hostnames = optional(string, "cp")
    node_hostnames          = optional(string, "node")
    custom_token            = optional(string, "")
    ip_pool_count           = optional(number, 0)
    kube_version            = optional(string, "")
    metallb_version         = optional(string, "")
    rancher_flavor          = optional(string, "")
    rancher_version         = optional(string, "")
    custom_rancher_password = optional(string, "")
  }))
  default = [{}]
}
