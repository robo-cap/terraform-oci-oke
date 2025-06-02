# Copyright (c) 2022, 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for GPU Memory Cluster groups defined in worker_pools
resource "oci_core_compute_gpu_memory_cluster" "workers" {
  # Create an OCI GPU Memory cluster resource for each enabled entry of the worker_pools map with that mode.
  for_each             = local.enabled_gpu_memory_clusters
  compartment_id       = each.value.compartment_id
  compute_cluster_id   = (lookup(oci_core_compute_cluster.shared, lookup(each.value, "compute_cluster", ""), null) != null ?
    oci_core_compute_cluster.shared[lookup(each.value, "compute_cluster", "")].id :
    (lookup(oci_core_compute_cluster.workers, each.key, null) != null ?
      oci_core_compute_cluster.workers[each.key].id :
      lookup(each.value, "compute_cluster", null)
    )
  )
  availability_domain  = (lookup(oci_core_compute_cluster.shared, lookup(each.value, "compute_cluster", ""), null) != null ?
    oci_core_compute_cluster.shared[lookup(each.value, "compute_cluster", "")].availability_domain :
    lookup(each.value, "placement_ad", null) != null ? lookup(var.ad_numbers_to_names, lookup(each.value, "placement_ad")) : element(each.value.availability_domains, 0)
  )
  instance_configuration_id = oci_core_instance_configuration.workers[each.key].id
  
  display_name         = each.key
  defined_tags         = each.value.defined_tags
  freeform_tags        = each.value.freeform_tags
  size                 = each.value.size
  gpu_memory_fabric_id = try(each.value.gpu_memory_fabric_id, null)


  lifecycle {
    ignore_changes = [
      display_name, defined_tags, freeform_tags,
    ]
  }

  # First-boot hardware config for bare metal instances takes extra time
  timeouts {
    create = "2h"
  }
}
