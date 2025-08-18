variable "instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
}
variable "profile" {
  description = "The AWS profile aligned with the AWS environment to deploy to"
  type        = string
}
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}
variable "key_name" {
  description = "Key name used for ec2 instances"
  type        = string
}
variable "instance_size" {
  description = "EC2 instance type to use for the test instance"
  type        = string
}
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}
variable "instance_volume_size" {
  description = "Size of the root volume for the EC2 instance in GB"
  type        = string
}
variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
}
variable "prod_ou_env" {
  description = "OU environment production."
  type        = string
}

variable "admins_ad_group" {
  description = "AD group for admins."
  type        = string
}

variable "domain_join_user_name" {
  description = "Username for domain join."
  type        = string
}

variable "ad_secrets_path" {
  description = "Path to AD secrets."
  type        = string
}

variable "domain_name" {
  description = "The Active Directory domain name."
  type        = string
}

variable "dom_disname" {
  description = "The distinguished name for the domain (e.g., dc=corp,dc=coalfire,dc=com)."
  type        = string
}