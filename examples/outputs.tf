
output "ec2_instance_ids" {
  description = "The IDs of the EC2 instances created by the module."
  value       = module.ec2_test.instance_id
}

output "ec2_primary_private_ip_addresses" {
  description = "A list of the primary private IP addresses assigned to the EC2 instances."
  value       = module.ec2_test.primary_private_ip_addresses
}

output "ec2_tags" {
  description = "Tags applied to the EC2 instances."
  value       = module.ec2_test.tags
}

output "ec2_security_group_id" {
  description = "The ID of the security group created by the module."
  value       = module.ec2_test.sg_id
}

output "ec2_iam_profile" {
  description = "The name of the IAM profile created by the module."
  value       = module.ec2_test.iam_profile
}

output "ec2_iam_role_arn" {
  description = "The ARN of the IAM role created by the module."
  value       = module.ec2_test.iam_role_arn
}

output "ec2_iam_role_name" {
  description = "The name of the IAM role created by the module."
  value       = module.ec2_test.iam_role_name
}

output "ec2_network_interface_ids" {
  description = "The network interface IDs for the EC2 instances."
  value       = module.ec2_test.network_interface_id
}
