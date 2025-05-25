# Copyright (c) 2022, 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl


resource "oci_identity_policy" "operator_policy" {
  count = var.create_cluster != null && var.create_operator_policy_to_manage_cluster ? 1 : 0

  provider = oci.home

  compartment_id = var.compartment_id
  description    = "Policies for OKE Operator host state ${var.state_id}"
  name           = "oke-operator-${var.state_id}"
  statements = [
    "ALLOW any-user to manage cluster-family in compartment id ${var.compartment_id} where all {target.cluster.id = '${var.cluster_id}', request.principal.type = 'instance', request.principal.id = '${oci_core_instance.operator.id}'}"
  ]
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
