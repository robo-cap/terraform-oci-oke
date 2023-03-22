# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "utilities" {
  source = "./modules/utilities"
  region = var.region

  # Cluster
  await_node_readiness = var.await_node_readiness
  expected_node_count  = local.worker_count_expected
  worker_pools         = one(module.workers[*].worker_pools)

  # Bastion/operator connection
  ssh_private_key = local.ssh_private_key
  bastion_host    = local.bastion_public_ip
  bastion_user    = var.bastion_user
  operator_host   = local.operator_private_ip
  operator_user   = var.operator_user

  # OCIR
  ocir_email_address    = var.ocir_email_address
  ocir_secret_id        = var.ocir_secret_id
  ocir_secret_name      = var.ocir_secret_name
  ocir_secret_namespace = var.ocir_secret_namespace
  ocir_username         = var.ocir_username

  providers = {
    oci.home = oci.home
  }
}