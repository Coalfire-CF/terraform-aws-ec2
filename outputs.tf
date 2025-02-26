output "instance_id" {
  description = "The AWS Instance id created"
  value       = aws_instance.this[*].id
}

output "sg_id" {
  description = "The id of the security group created"
  value       = module.security_group[*].id
}

output "iam_profile" {
  description = "The name of the iam profile created in the module"
  value       = local.iam_profile
}

output "primary_private_ip_addresses" {
  description = "A list of the primary private IP addesses assigned to the ec2 instance"
  value       = aws_instance.this[*].private_ip
}

output "tags" {
  description = "List of tags of instances"
  value       = aws_instance.this[*].tags
}

output "iam_role_arn" {
  description = "The AWS IAM Role arn created"
  value       = aws_iam_role.this_role[*].arn
}
output "iam_role_name" {
  description = "The AWS IAM Role arn created"
  value       = aws_iam_role.this_role[*].name
}

output "network_interface_id" {
  description = "The network interface ID for the AWS instance"
  value = aws_instance.this[*].primary_network_interface_id
}
