locals {
  iam_profile = length(aws_iam_instance_profile.this_profile) > 0 ? aws_iam_instance_profile.this_profile[0].name : var.iam_profile
  create_sg   = length(var.ingress_rules) > 0 || length(var.egress_rules) > 0 ? 1 : 0
}

# Gathers user data from maps listed in module calls
locals {
  user_data = var.user_data == null ? null : [
    for script in var.user_data : templatefile(
      "${script["path"]["module_directory"]}/${script["path"]["folder_name"]}/${script["path"]["file_name"]}",
      script["vars"]
    )
  ]
}

# For lb attachment
locals {
  full_size = length(aws_instance.this.*.id) * length(var.target_group_arns)
}

# For additional sg attachment
locals {
  additional_sg_to_primary_eni    = setproduct(var.additional_security_groups, aws_instance.this.*.primary_network_interface_id)
  additional_sg_to_additional_eni = setproduct(var.additional_security_groups, var.additional_eni_ids)
}

# For additional ebs attachment
locals {
  # Sorting workaround graciously stolen from https://josusb.com/blog/terraform-sort/
  sorted_instance_values = reverse(distinct(sort([
    for instance in aws_instance.this[*]: instance.availability_zone
  ])))

  sorted_instance_ids = compact(flatten([
    for value in local.sorted_instance_values: [
      for instance in aws_instance.this[*]: 
        instance.id if instance.availability_zone == value
    ]
  ]))

  sorted_ebs_values = reverse(distinct(sort([
    for volume in aws_ebs_volume.this: volume.availability_zone
  ])))

  sorted_ebs_ids = compact(flatten([
    for value in local.sorted_ebs_values: [
      for volume in aws_ebs_volume.this: 
        volume.id if volume.availability_zone == value
    ]
  ]))

  additional_ebs_volumes = zipmap(local.sorted_instance_ids, local.sorted_ebs_ids)

}
