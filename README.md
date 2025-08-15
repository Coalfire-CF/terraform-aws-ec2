
![Coalfire](coalfire_logo.png)

# terraform-aws-ec2

## Description

The EC2 module provisions one or more AWS EC2 instances with flexible configuration for networking, storage, IAM, tagging, security groups, and load balancer target group attachments. It supports single or multiple instances, multiple ENIs, custom EBS volumes, and integration with existing IAM profiles and security groups.

## Dependencies

The following modules or resources should be created prior to deploying this module:

- [terraform-aws-vpc-nfw](https://github.com/Coalfire-CF/terraform-aws-vpc-nfw) (for VPC and subnets)
- [terraform-aws-account-setup](https://github.com/Coalfire-CF/terraform-aws-account-setup) (for IAM roles/profiles and KMS key)
- Any security groups or IAM policies you wish to attach


## Tree

```
.
├── CONTRIBUTING.md
├── README.md
├── coalfire_logo.png
├── ebs.tf
├── ec2.tf
├── eip.tf
├── enis.tf
├── examples
│   ├── data.tf
│   ├── example.auto.tfvars
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── required-providers.tf
│   ├── userdata
│   │   └── ud-os-join-ad.sh
│   └── variables.tf
├── iam.tf
├── locals.tf
├── outputs.tf
├── required_providers.tf
├── sg.tf
├── target_group_attachment.tf
└── variables.tf

```

## Resource List

- EC2 instance(s)
- Elastic IP (optional)
- Network interface attachment (optional)
- IAM role and instance profile (optional)
- KMS grant for EBS encryption (optional)
- Security group (optional)
- Target group attachment (optional)
- EBS volumes and attachments (optional)


## Usage
This is an example of how to create an EC2 instance using this module, with generic variables.

```hcl
module "ec2_test" {
  source = "github.com/Coalfire-CF/terraform-aws-ec2?ref=vX.X.X"

  name = var.instance_name

  ami               = data.aws_ami.ami.id
  ec2_instance_type = var.instance_size
  instance_count    = var.instance_count

  vpc_id = aws_vpc.main.id
  subnet_ids = var.subnet_ids

  ec2_key_pair    = var.key_name
  ebs_kms_key_arn = data.terraform_remote_state.kms.outputs.ebs_kms_key_arn

  # Storage
  root_volume_size = var.instance_volume_size

  # Security Group Rules
    ingress_rules = {
    "rdp" = {
      ip_protocol = "tcp"
      from_port   = "3389"
      to_port     = "3389"
      cidr_ipv4   = var.cidr_for_remote_access
      description = "RDP"
    }
  }

  egress_rules = {
    "allow_all_egress" = {
      ip_protocol = "-1"
      from_port   = "0"
      to_port     = "0"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress"
    }
  }

  # Tagging
  global_tags = {}
}
```

### User Data

```hcl-terraform
  user_data = templatefile("${path.module}/../../shellscripts/linux/ud-os-join-ad.sh", {
    aws_region            = var.aws_region
    domain_name           = local.domain_name
    dom_disname           = local.dom_disname
    ou_env                = var.lin_prod_ou_env
    linux_admins_ad_group = var.linux_admins_ad_group
    domain_join_user_name = var.domain_join_user_name
    sm_djuser_path        = "${var.ad_secrets_path}${var.domain_join_user_name}"
    is_asg                = "false"
  })
```

### Security Groups
Ingress Rules:
```hcl-terraform
ingress_rules = {
    "rdp" = {
      ip_protocol = "tcp"
      from_port   = "3389"
      to_port     = "3389"
      cidr_ipv4   = var.cidr_for_remote_access
      description = "RDP"
    }
  }
```

Egress Rules:
```hcl-terraform
egress_rules = {
    "allow_all_egress" = {
      ip_protocol = "-1"
      from_port   = "0"
      to_port     = "0"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all egress"
    }
  }
```

### IAM

```hcl-terraform
iam_policies      = [aws_iam_policy.test_policy_1.arn, ...]

```

### Multiple EBS Volumes

The root ebs volume is handled with the below variables:

However, if additional ebs volumes are required, you can use the below variable:

```hcl-terraform
ebs_block_devices = [
    {
      device_name = "/dev/sdf"
      volume_size = "50"
      volume_type = "gp2"
    },
    ...
  ]

```

### Attaching Security Groups or IAM Profile from other instances

The module also supports attaching a security group or IAM Profile from another instance within the same directory.  Let's take an example:
AD1 creates a security group that can be used by both AD1 and AD2.  So, the AD2 module should use the output of the AD1 module to assign the existing security group.  Note, AD2 would now have a dependency on AD1.
As shown below, the "additional_security_groups" variable can be used for this purpose.

 ```hcl-terraform
module "ad2" {
  source = "github.com/Coalfire-CF/terraform-aws-ec2?ref=vX.X.X"
  name              = "dc2"
  ami               = "ami-XXXXXX"
  ec2_instance_type = "m5a.large"
  ec2_key_pair      = var.key_name
  root_volume_size  = "50"
  subnet_ids        = [data.terraform_remote_state.network-mgmt.outputs.private_subnets[X]]
  vpc_id            = data.terraform_remote_state.network-mgmt.outputs.vpc_id
  private_ip = "${var.ip_network_mgmt}.${var.directory_ip_2}"


  iam_profile = module.ad1.iam_profile
  additional_security_groups = [module.ad1.sg_id]
}
```
See the [examples/simple](examples/simple/README.md) directory for a full working example.


## Environment Setup

IAM user authentication:

- Download and install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Log into the AWS Console and create AWS CLI Credentials ([guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html))
- Configure the named profile used for the project, e.g. `aws configure --profile example-mgmt`

SSO-based authentication (via IAM Identity Center SSO):

- Login to the AWS IAM Identity Center console, select the permission set for MGMT, and select the 'Access Keys' link.
- Choose the 'IAM Identity Center credentials' method to get the SSO Start URL and SSO Region values.
- Run `aws configure sso --profile example-mgmt` and follow the prompts.
- Verify you can run AWS commands successfully, e.g. `aws s3 ls --profile example-mgmt`.
- Run `export AWS_PROFILE=example-mgmt` in your terminal to use the specific profile and avoid having to use `--profile` option.

## Deployment

1. Navigate to the Terraform project and create a parent directory in the upper level code, for example:

  ```hcl
  ../aws/terraform/{REGION}/management-account/example
  ```

  If multi-account management plane:

  ```hcl
  ../aws/terraform/{REGION}/{ACCOUNT_TYPE}-mgmt-account/example
  ```


1. Create a new branch. The branch name should provide a high level overview of what you're working on.

1. Create a properly defined main.tf file via the template found under 'Usage' while adjusting tfvars as needed. Example parent directory:

  ```hcl
  ├── Example/
  │   ├── prefix.auto.tfvars
  │   ├── data.tf
  │   ├── locals.tf
  │   ├── main.tf
  │   ├── outputs.tf
  │   ├── providers.tf
  │   ├── README.md
  │   ├── tstate.tf
  │   ├── variables.tf
  │   ├── ...
  ```

1. Change directories to the `terraform-aws-ec2` directory.

1. Ensure that the `prefix.auto.tfvars` variables are correct (especially the profile) or create a new tfvars file with the correct variables.

1. Customize code to meet requirements, e.g. add/remove inbound rules, add/remove outbound rules.

1. From the `terraform-aws-ec2` directory, initialize the Terraform working directory:

  ```hcl
  terraform init
  ```


1. Standardized formatting in code:

  ```hcl
  terraform fmt
  ```


1. Optional: Ensure proper syntax and "spell check" your code:

  ```hcl
  terraform validate
  ```


1. Create an execution plan and verify everything looks correct:

   ```hcl
   terraform plan
   ```


1. Apply the configuration:

   ```hcl
   terraform apply
   ```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/downloads.html) | >=1.5 |
| [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) | >= 5.15.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.15.0, < 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| security_group | github.com/Coalfire-CF/terraform-aws-securitygroup | v1.0.1 |

## Resources

| Name | Type |
|------|------|
| aws_ebs_volume.this | resource |
| aws_eip.eip | resource |
| aws_eip_association.eip_attach | resource |
| aws_iam_instance_profile.this_profile | resource |
| aws_iam_role.this_role | resource |
| aws_iam_role_policy_attachment.iam_policy_attach | resource |
| aws_iam_role_policy_attachment.ssm_role_policy_attach | resource |
| aws_instance.this | resource |
| aws_kms_grant.kms_key_grant | resource |
| aws_lb_target_group_attachment.target_group_attachment | resource |
| aws_network_interface_attachment.eni_attachment | resource |
| aws_network_interface_sg_attachment.additional | resource |
| aws_volume_attachment.this | resource |
| aws_ec2_instance_type.this | data source |
| aws_iam_policy.AmazonSSMManagedInstanceCore | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| add_SSMManagedInstanceCore | Whether or not to apply the SSMManagedInstanceCore to the IAM role | bool | true | no |
| additional_eni_ids | This variable allows for an ec2 instance to have multiple ENIs.  Instance count must be set to 1 | list(string) | [] | no |
| additional_security_groups | List of additional security group IDs to attach to the EC2 instance | list(string) | [] | no |
| ami | ID of AMI to use for the instance | string | n/a | yes |
| associate_eip | Whether or not to associate an Elastic IP | bool | false | no |
| associate_public_ip | Whether or not to associate a public IP (not EIP) | bool | false | no |
| assume_role_policy | Policy document allowing Principals to assume this role (e.g. Trust Relationship) | string | ...default... | no |
| create_security_group | Whether to create a security group for this EC2 instance | bool | true | no |
| ebs_block_devices | A list of maps that contains 3 keys: device name, volume size, and volume type | list(object({ device_name = string, volume_size = number, volume_type = string })) | [] | no |
| ebs_kms_key_arn | The ARN of the KMS key to encrypt EBS volumes | string | n/a | yes |
| ebs_optimized | Whether or not the instance is ebs optimized | bool | true | no |
| ebs_volumes | A list of maps for additional EBS volumes | list(object({ ... })) | [] | no |
| ec2_instance_type | The type of instance to start | string | n/a | yes |
| ec2_key_pair | The key name to use for the instance | string | n/a | yes |
| egress_rules | The list of rules for egress traffic | map(object({ ... })) | {} | no |
| get_password_data | Whether or not to allow retrieval of the local admin password | bool | false | no |
| global_tags | a map of strings that contains global level tags | map(string) | n/a | yes |
| http_endpoint | Whether the metadata service is available | string | "enabled" | no |
| http_put_response_hop_limit | Number of network hops to allow instance metadata | number | 1 | no |
| http_tokens | Whether or not the metadata service requires session tokens | string | "required" | no |
| iam_policies | A list of the iam policy ARNs to attach to the IAM role | list(string) | [] | no |
| iam_profile | A variable to attach an existing iam profile to the ec2 instance(s) created | string | "" | no |
| ingress_rules | The list of rules for ingress traffic | map(object({ ... })) | {} | no |
| instance_count | Number of instances to launch | number | 1 | no |
| instance_metadata_tags | Enables or disables access to instance tags from the instance metadata service | string | "enabled" | no |
| keys_to_grant | A list of kms keys to grant permissions to for the role created | list(string) | [] | no |
| name | The name of the ec2 instance | string | n/a | yes |
| private_ip | Single private IP for a single instance | string | null | no |
| private_ips | List of private IPs for multiple instances | list(string) | [] | no |
| root_volume_size | The size of the root ebs volume on the ec2 instances created | string | n/a | yes |
| root_volume_type | The type of the root ebs volume on the ec2 instances created | string | "gp3" | no |
| sg_description | This overwrites the default generated description for the security group | string | "Managed by Terraform" | no |
| source_dest_check | Whether or not source/destination check should be enabled for the primary network interface | bool | true | no |
| subnet_ids | A list of the subnets to be used when provisioning ec2 instances | list(string) | n/a | yes |
| tags | A mapping of tags to assign to the resource | map(string) | {} | no |
| target_group_arns | A list of aws_alb_target_group ARNs, for use with Application Load Balancing | list(string) | [] | no |
| user_data | The User Data script to run | string | null | no |
| user_data_base64 | Can be used instead of user_data to pass base64-encoded binary data directly | string | null | no |
| user_data_replace_on_change | When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true | bool | null | no |
| volume_delete_on_termination | Whether to delete attached EBS volumes when their EC2 instance is terminated | bool | false | no |
| vpc_id | The id of the vpc where resources are being created | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| iam_profile | The name of the iam profile created in the module |
| iam_role_arn | The AWS IAM Role arn created |
| iam_role_name | The AWS IAM Role arn created |
| instance_id | The AWS Instance id created |
| network_interface_id | The network interface ID for the AWS instance |
| primary_private_ip_addresses | A list of the primary private IP addesses assigned to the ec2 instance |
| sg_id | The id of the security group created |
| tags | List of tags of instances |
<!-- END_TF_DOCS -->

## Contributing

[Start Here](CONTRIBUTING.md)

## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)

## Contact Us

[Coalfire](https://coalfire.com/)

### Copyright

© 2025 Coalfire Systems Inc.
