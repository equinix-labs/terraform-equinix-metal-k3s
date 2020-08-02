variable "auth_token" {
  description = "Your Packet API key"
}

variable "project_id" {
  description = "Your Packet Project ID"
}

variable "ssh_private_key_path" {
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
  description = "Core site, node-pool attached facility"
  default     = "newark"
}

variable "plan_primary" {
  description = "Plan for ARM Nodes"
  default     = "baremetal_2a"
}

variable "plan_node" {
  description = "Plan for ARM Nodes"
  default     = "baremetal_2a"
}

variable "node_count" {
  default     = "1"
  description = "Number of ARM nodes."
}

variable "cluster_name" {
  default = "packet-k3s"
  description = "The cluster project name, will prepend hostnames"
}
