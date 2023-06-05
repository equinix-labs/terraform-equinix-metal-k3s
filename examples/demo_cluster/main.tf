provider "equinix" {
  auth_token = var.metal_auth_token
}

module "demo" {
  # source = "equinix/k3s/metal"
  source = "../.."

  metal_project_id = var.metal_project_id
  global_ip        = var.global_ip
  deploy_demo      = var.deploy_demo
  clusters         = var.clusters
}
