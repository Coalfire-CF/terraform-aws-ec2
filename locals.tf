locals {
  iam_profile = length(aws_iam_instance_profile.this_profile) > 0 ? aws_iam_instance_profile.this_profile[0].name : var.iam_profile
  create_sg   = length(var.ingress_rules) > 0 || length(var.egress_rules) > 0 ? 1 : 0
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
  additional_ebs_volumes = setproduct(aws_instance.this[*], var.ebs_volumes)
}
