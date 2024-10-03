terraform {
  required_version = ">= 1.9"
  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = ">= 1.14.2"
    }
  }
  provider_meta "equinix" {
    module_name = "equinix/k3s"
  }
}
