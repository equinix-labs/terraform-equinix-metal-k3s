variable "auth_token" {
  description = "Your Packet API key"
}

variable "project_id" {
  description = "Your Packet Project ID"
}

variable "ssh_private_key_path" {
  description = "Your SSH private key path (used locally only)"
}

variable "facility" {
  description = "Your primary facility"
  default     = "nrt1"
}

variable "plan_primary" {
  description = "Plan for ARM Nodes"
  default     = "baremetal_2a"
}

variable "plan_node" {
  description = "Plan for ARM Nodes"
  default     = "baremetal_2a"
}

variable "count" {
  default     = "1"
  description = "Number of ARM nodes."
}
