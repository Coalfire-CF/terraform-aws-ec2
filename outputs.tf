locals {
  iam_profile = length(aws_iam_instance_profile.this_profile) > 0 ? aws_iam_instance_profile.this_profile[0].name : var.iam_profile
  sg_id = length(var.cidr_security_group_rules) > 0 || length(var.sg_security_group_rules) > 0 ? aws_security_group.this[0].id : ""
//  public_private_ip_addresses = length(var.additional_enis["public"]) > 0 ? aws_network_interface.public.*.private_ip : []
//  private_private_ip_addresses = length(var.additional_enis["private"]) > 0 ? aws_network_interface.private.*.private_ip : []
//  public_public_ip_addresses = length(var.additional_enis["public"]) > 0 ? aws_eip.eip_multi_eni.*.public_ip : []
}

output "instance_id" {
  description = "The AWS Instance id created"
  value       = aws_instance.this.*.id
}

output "sg_id" {
  description = "The id of the security group created"
  value = local.sg_id
}

output "iam_profile" {
  description = "The name of the iam profile created in the module"
  value = local.iam_profile
}

output "primary_private_ip_addresses" {
  description = "A list of the primary private IP addesses assigned to the ec2 instance"
  value = aws_instance.this.*.private_ip
}

output "tags" {
  description = "List of tags of instances"
  value       = aws_instance.this.*.tags
}

//output "public_private_ip_addresses" {
//  description = "A list of the private IP addesses for the public interfaces assigned to the ec2 instance"
//  value = local.public_private_ip_addresses
//}
//
//output "private_private_ip_addresses" {
//  description = "A list of the private IP addesses for the private interfaces assigned to the ec2 instance"
//  value = local.private_private_ip_addresses
//}
//
//output "public_public_ip_addresses" {
//  description = "A list of the public IP addesses for the public interfaces assigned to the ec2 instance"
//  value = local.public_public_ip_addresses
//}

output "iam_role_arn" {
  description = "The AWS IAM Role arn created"
  value       = aws_iam_role.this_role.*.arn
}