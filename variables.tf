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

variable "ebs_block_devices" {
  description = "A list of maps that contains 3 keys: device name, volume size, and volume type"
  type = list(object({
    device_name = string
    volume_size = string
    volume_type = string
  }))
  default = []
}

variable "volume_delete_on_termination" {
  description = "Whether to delete attached EBS volumes when their EC2 instance is terminated"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "Whether or not the instance is ebs optimized"
  type        = bool
  default     = false
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
  type = list(object({
    protocol         = string
    from_port        = string
    to_port          = string
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    prefix_list_ids  = optional(list(string), [])
    security_groups  = optional(list(string), [])
    self             = optional(bool)
    description      = optional(string, "Managed by Terraform")
  }))
  default = []
}

variable "egress_rules" {
  description = "The list of rules for egress traffic. Required fields for each rule are 'protocol', 'from_port', 'to_port', and at least one of 'cidr_blocks', 'ipv6_cidr_blocks', 'security_groups', 'self', or 'prefix_list_sg'. Optional fields are 'description' and those not used from the previous list"
  type = list(object({
    protocol         = string
    from_port        = string
    to_port          = string
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    prefix_list_ids  = optional(list(string), [])
    security_groups  = optional(list(string), [])
    self             = optional(bool)
    description      = optional(string, "Managed by Terraform")
  }))
  default = []
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
  description = "a list of maps that contain the path to the user data script (starting at the shellScript folder) and the variables for that script."
  type        = list(map(any))
  default     = []
}

variable "user_data_gzip" {
  description = "Whether or not to gzip the user data for the instance"
  type        = bool
  default     = true
}

variable "simple_user_data" {
  description = "Simple string for 1 liner user data"
  type        = string
  default     = ""
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

variable "module_depends_on" {
  description = "A variable to simulate the depends on feature that resources have"
  type        = any
  default     = null
}
