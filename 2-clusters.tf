module "cluster_facility" {
  source = "modules/cluster_pool"

  cluster_name                   = "primary"
  count                          = "${var.count}"
  plan_primary                   = "${var.plan_primary}"
  plan_node                      = "${var.plan_node}"
  facility                       = "${var.facility}"
  auth_token                     = "${var.auth_token}"
  project_id                     = "${var.project_id}"
  ssh_private_key_path           = "${var.ssh_private_key_path}"
}

#Subsequent Clusters will be populated below this line. See README for spin-up procedure.

