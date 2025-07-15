# Copyright (c) 2017, 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  lustre_nsg_config = try(var.nsgs.lustre, { create = "never" })
  lustre_nsg_create = coalesce(lookup(local.lustre_nsg_config, "create", null), "auto")
  lustre_nsg_enabled = anytrue([
    local.lustre_nsg_create == "always",
    alltrue([
      local.lustre_nsg_create == "auto",
      coalesce(lookup(local.lustre_nsg_config, "id", null), "none") == "none",
      var.create_cluster,
    ]),
  ])
  # Return provided NSG when configured with an existing ID or created resource ID
  lustre_nsg_id = one(compact([try(var.nsgs.lustre.id, null), one(oci_core_network_security_group.lustre[*].id)]))
  lustre_rules = local.lustre_nsg_enabled ? {
    # See https://docs.oracle.com/en-us/iaas/Content/lustre/security-rules.htm
    # Ingress
    "Allow TCP connection from Workers" : {
      protocol = local.tcp_protocol, source_port_min = local.lustre_port_min, source_port_max = local.lustre_port_max, port=local.lustre_lnet_port, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
    },
    "Allow TCP connection from LustreFS nodes" : {
      protocol = local.tcp_protocol, source_port_min = local.lustre_port_min, source_port_max = local.lustre_port_max, port=local.lustre_lnet_port, source = local.lustre_nsg_id, source_type = local.rule_type_nsg,
    },

    # Egress
    "Allow TCP connection to Workers" : {
      protocol = local.tcp_protocol, source_port_min = local.lustre_port_min, source_port_max = local.lustre_port_max, port=local.lustre_lnet_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
    },
    "Allow TCP connection to LustreFS nodes" : {
      protocol = local.tcp_protocol, source_port_min = local.lustre_port_min, source_port_max = local.lustre_port_max, port=local.lustre_lnet_port, destination = local.lustre_nsg_id, destination_type = local.rule_type_nsg,
    }
  } : {}
}

resource "oci_core_network_security_group" "lustre" {
  count          = local.lustre_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "lustre-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, display_name, vcn_id]
  }
}

output "lustre_nsg_id" {
  value = local.lustre_nsg_id
}
