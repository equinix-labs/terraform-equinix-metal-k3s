variable "auth_token" {
  description = "Your Packet API key"
}

variable "facility" {
  description = "Packet Facility"
  default     = "ewr1"
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
