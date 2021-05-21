variable "auth_token" {
  type        = string
  sensitive   = true
  description = "Your Equinix Metal API key"
}

variable "project_id" {
  type        = string
  description = "Your Equinix Metal Project ID"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Your SSH private key path (used locally only)"
}

variable "facilities" {
  type = map(string)

  default = {
    newark  = "ewr1"
    narita  = "nrt1"
    sanjose = "sjc1"
  }
}

variable "primary_facility" {
  type        = string
  description = "Core site, node-pool attached facility"
  default     = "newark"
}

variable "plan_primary" {
  type        = string
  description = "Plan for ARM Nodes"
  default     = "c3.small"
}

variable "plan_node" {
  type        = string
  description = "Plan for ARM Nodes"
  default     = "c3.small"
}

variable "node_count" {
  type        = number
  default     = "1"
  description = "Number of ARM nodes."
}

variable "cluster_name" {
  type        = string
  default     = "metal-k3s"
  description = "The cluster project name, will prepend hostnames"
}
