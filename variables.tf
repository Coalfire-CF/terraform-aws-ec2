variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 1
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
}

variable "name" {
  description = "The name of the ec2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "ec2_key_pair" {
  description = "The key name to use for the instance"
  type        = string
}

variable "root_volume_type" {
  description = "The type of the root ebs volume on the ec2 instances created"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "The size of the root ebs volume on the ec2 instances created"
  type        = string
}

variable "ebs_volumes" {
  description = "A list of maps that must contain device_name (ex. '/dev/sdb') and size (in GB). Optional args include type, throughput, iops, multi_attach_enabled, final_snapshot, snapshot_id, outpost_arn, force_detach, skip_destroy, stop_instance_before_detaching, and tags"
  type = list(object({
    device_name                    = string
    size                           = number
    type                           = string
    throughput                     = optional(number)
    iops                           = optional(number)
    multi_attach_enabled           = optional(bool, false)
    final_snapshot                 = optional(string)
    snapshot_id                    = optional(string)
    outpost_arn                    = optional(string)
    force_detach                   = optional(bool, false)
    skip_destroy                   = optional(bool, false)
    stop_instance_before_detaching = optional(bool, false)
    tags                           = optional(map(string), {})
  }))
  default = []
}

variable "ebs_optimized" {
  description = "Whether or not the instance is ebs optimized"
  type        = bool
  default     = true
}

variable "ebs_kms_key_arn" {
  description = "The ARN of the KMS key to encrypt EBS volumes"
  type        = string
}

variable "target_group_arns" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  default     = []
  type        = list(string)
}

variable "vpc_id" {
  description = "The id of the vpc where resources are being created"
  type        = string
}

variable "subnet_ids" {
  description = "A list of the subnets to be used when provisioning ec2 instances.  If instance count is 1, only the first subnet will be used"
  type        = list(string)
}

variable "private_ip" {
  description = "The private ip for the instance"
  type        = string
  default     = null
}

variable "additional_security_groups" {
  description = "A list of additional security groups to attach to the network interfaces"
  type        = list(string)
  default     = []
}

variable "associate_public_ip" {
  description = "Whether or not to associate a public IP (not EIP)"
  type        = bool
  default     = false
}

variable "associate_eip" {
  description = "Whether or not to associate an Elastic IP"
  type        = bool
  default     = false
}

variable "sg_description" {
  description = "This overwrites the default generated description for the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "ingress_rules" {
  description = "The list of rules for ingress traffic. Required fields for each rule are 'protocol', 'from_port', 'to_port', and at least one of 'cidr_blocks', 'ipv6_cidr_blocks', 'security_groups', 'self', or 'prefix_list_sg'. Optional fields are 'description' and those not used from the previous list"
  type = map(object({
    cidr_ipv4                    = optional(string, null)
    cidr_ipv6                    = optional(string, null)
    description                  = optional(string, "Managed by Terraform")
    from_port                    = optional(string, null)
    ip_protocol                  = optional(string, null)
    prefix_list_id               = optional(string, null)
    referenced_security_group_id = optional(string, null)
    to_port                      = optional(string, null)
  }))
  default = {}
}

variable "egress_rules" {
  description = "The list of rules for egress traffic. Required fields for each rule are 'protocol', 'from_port', 'to_port', and at least one of 'cidr_blocks', 'ipv6_cidr_blocks', 'security_groups', 'self', or 'prefix_list_sg'. Optional fields are 'description' and those not used from the previous list"
  type = map(object({
    cidr_ipv4                    = optional(string, null)
    cidr_ipv6                    = optional(string, null)
    description                  = optional(string, "Managed by Terraform")
    from_port                    = optional(string, null)
    ip_protocol                  = optional(string, null)
    prefix_list_id               = optional(string, null)
    referenced_security_group_id = optional(string, null)
    to_port                      = optional(string, null)
  }))
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "global_tags" {
  description = "a map of strings that contains global level tags"
  type        = map(string)
}

variable "keys_to_grant" {
  description = "A list of kms keys to grant permissions to for the role created."
  type        = list(string)
  default     = []
}

variable "additional_eni_ids" {
  description = "This variable allows for an ec2 instance to have multiple ENIs.  Instance count must be set to 1"
  type        = list(string)
  default     = []
}

variable "source_dest_check" {
  description = "Whether or not source/destination check should be enabled for the primary network interface"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "The User Data script to run"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set"
  type        = bool
  default     = null
}

variable "get_password_data" {
  description = "Whether or not to allow retrieval of the local admin password"
  type        = bool
  default     = false
}

variable "iam_profile" {
  description = "A variable to attach an existing iam profile to the ec2 instance(s) created"
  type        = string
  default     = ""
}

variable "iam_policies" {
  description = "A list of the iam policy ARNs to attach to the IAM role"
  type        = list(string)
  default     = []
}

variable "add_SSMManagedInstanceCore" {
  description = "Whether or not to apply the SSMManagedInstanceCore to the IAM role"
  type        = bool
  default     = true
}

variable "assume_role_policy" {
  description = "Policy document allowing Principals to assume this role (e.g. Trust Relationship)"
  type        = string
  default     = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ec2.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

variable "http_tokens" {
  description = "Whether or not the metadata service requires session tokens, required=IMDSv2, optional=IMDSv1"
  type        = any
  default     = "required"
  validation {
    condition     = can(regex("^(required|optional)$", var.http_tokens))
    error_message = "ERROR: Valid values are 'required' or 'optional'."
  }
}