module "ec2_test" {
  source = "git::https://github.com/Coalfire-CF/terraform-aws-ec2?ref=v2.2.0"

  name = var.instance_name

  # AMI and instance configuration
  ami               = data.aws_ami.win_ami.id
  ec2_instance_type = var.instance_size
  instance_count    = var.instance_count

  # Networking configuration
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = [
    data.terraform_remote_state.networking.outputs.private_subnets["pak-subnet-testing-us-gov-west-1a"]
  ]

  # SSH key and KMS key for EBS encryption
  ec2_key_pair    = var.key_name
  ebs_kms_key_arn = data.terraform_remote_state.account_setup.outputs.ebs_kms_key_arn

  # Storage
  root_volume_size = var.instance_volume_size

  # Security Group Rules
  ingress_rules = {
    "ssh" = {
      ip_protocol = "tcp"
      from_port   = "22"
      to_port     = "22"
      cidr_ipv4   = "0.0.0.0/0"
      description = "SSH access from anywhere"
    }
  }

  egress_rules = {
    "allow_all_egress" = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress"
    }
  }

  # User data script for domain join and configuration
  user_data = templatefile("/userdata/ud-os-join-ad.sh", {
    aws_region            = var.aws_region
    domain_name           = local.domain_name
    dom_disname           = local.dom_disname
    ou_env                = var.prod_ou_env
    linux_admins_ad_group = var.admins_ad_group
    domain_join_user_name = var.domain_join_user_name
    sm_djuser_path        = "${var.ad_secrets_path}${var.domain_join_user_name}"
    is_asg                = "false"
  })

  # Additional EBS volumes attached to the instance
  ebs_volumes = [
    {
      device_name = "/dev/sdb"
      size        = 20
      type        = "gp3"
    },
    {
      device_name = "/dev/sdc"
      size        = 20
      type        = "gp3"
    }
  ]
  # Tagging
  global_tags = local.internal_tags
}