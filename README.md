
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
├── License.md
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
├── update-readme-tree.sh
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


## Environment Setup

Establish a secure connection to the Management AWS account used for the build:

```hcl
IAM user authentication:

- Download and install the AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Log into the AWS Console and create AWS CLI Credentials (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- Configure the named profile used for the project, such as 'aws configure --profile example-mgmt'

SSO-based authentication (via IAM Identity Center SSO):

- Login to the AWS IAM Identity Center console, select the permission set for MGMT, and select the 'Access Keys' link.
- Choose the 'IAM Identity Center credentials' method to get the SSO Start URL and SSO Region values.
- Run the setup command 'aws configure sso --profile example-mgmt' and follow the prompts.
- Verify you can run AWS commands successfully, for example 'aws s3 ls --profile example-mgmt'.
- Run 'export AWS_PROFILE=example-mgmt' in your terminal to use the specific profile and avoid having to use '--profile' option.
```


## Deployment

1. Navigate to the Terraform project and create a parent directory in the upper level code, for example:

    ```hcl
    ../{CLOUD}/terraform/{REGION}/management-account/example
    ```
   If multi-account management plane:

    ```hcl
    ../{CLOUD}/terraform/{REGION}/{ACCOUNT_TYPE}-mgmt-account/example
    ```

2. Create a properly defined main.tf file via the template found under 'Usage' while adjusting tfvars as needed. Note that many provided variables are outputs from other modules. Example parent directory:

      ```hcl
    ├── Example/
    │   ├── example.auto.tfvars   
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   ├── required-providers.tf
    │   ├── remote-data.tf
    │   ├── variables.tf 
    │   ├── ...
      ```


3. Change directories to the terraform-aws-ec2 directory.

    Ensure that the example.auto.tfvars variables are correct (especially the profile)

    Customize code to meet requirements, e.g. add/remove inbound rules, add/remove outbound rules.
   
4. Initialize the Terraform working directory:
    ```hcl
    terraform init
    ```
    Create an execution plan and verify the resources being created:
    ```hcl
    terraform plan
    ```
    Apply the configuration:
    ```hcl
    terraform apply
    ```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.15.0, < 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.15.0, < 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | github.com/Coalfire-CF/terraform-aws-securitygroup | v1.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.eip_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.this_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.iam_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_role_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_kms_grant.kms_key_grant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [aws_lb_target_group_attachment.target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_network_interface_attachment.eni_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_network_interface_sg_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_sg_attachment) | resource |
| [aws_volume_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ec2_instance_type.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |
| [aws_iam_policy.AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_SSMManagedInstanceCore"></a> [add\_SSMManagedInstanceCore](#input\_add\_SSMManagedInstanceCore) | Whether or not to apply the SSMManagedInstanceCore to the IAM role | `bool` | `true` | no |
| <a name="input_additional_eni_ids"></a> [additional\_eni\_ids](#input\_additional\_eni\_ids) | This variable allows for an ec2 instance to have multiple ENIs.  Instance count must be set to 1 | `list(string)` | `[]` | no |
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | List of additional security group IDs to attach to the EC2 instance | `list(string)` | `[]` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `string` | n/a | yes |
| <a name="input_associate_eip"></a> [associate\_eip](#input\_associate\_eip) | Whether or not to associate an Elastic IP | `bool` | `false` | no |
| <a name="input_associate_public_ip"></a> [associate\_public\_ip](#input\_associate\_public\_ip) | Whether or not to associate a public IP (not EIP) | `bool` | `false` | no |
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | Policy document allowing Principals to assume this role (e.g. Trust Relationship) | `string` | `"{\n \"Version\": \"2012-10-17\",\n \"Statement\": [\n   {\n     \"Action\": \"sts:AssumeRole\",\n     \"Principal\": {\n       \"Service\": \"ec2.amazonaws.com\"\n     },\n     \"Effect\": \"Allow\",\n     \"Sid\": \"\"\n   }\n ]\n}\n"` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a security group for this EC2 instance | `bool` | `true` | no |
| <a name="input_ebs_block_devices"></a> [ebs\_block\_devices](#input\_ebs\_block\_devices) | A list of maps that contains 3 keys: device name, volume size, and volume type | <pre>list(object({<br/>    device_name = string<br/>    volume_size = number<br/>    volume_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_ebs_kms_key_arn"></a> [ebs\_kms\_key\_arn](#input\_ebs\_kms\_key\_arn) | The ARN of the KMS key to encrypt EBS volumes | `string` | n/a | yes |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Whether or not the instance is ebs optimized | `bool` | `true` | no |
| <a name="input_ebs_volumes"></a> [ebs\_volumes](#input\_ebs\_volumes) | A list of maps that must contain device\_name (ex. '/dev/sdb') and size (in GB). Optional args include type, throughput, iops, multi\_attach\_enabled, final\_snapshot, snapshot\_id, outpost\_arn, force\_detach, skip\_destroy, stop\_instance\_before\_detaching, and tags | <pre>list(object({<br/>    device_name                    = string<br/>    size                           = number<br/>    type                           = string<br/>    throughput                     = optional(number)<br/>    iops                           = optional(number)<br/>    multi_attach_enabled           = optional(bool, false)<br/>    final_snapshot                 = optional(string)<br/>    snapshot_id                    = optional(string)<br/>    outpost_arn                    = optional(string)<br/>    force_detach                   = optional(bool, false)<br/>    skip_destroy                   = optional(bool, false)<br/>    stop_instance_before_detaching = optional(bool, false)<br/>    tags                           = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | The type of instance to start | `string` | n/a | yes |
| <a name="input_ec2_key_pair"></a> [ec2\_key\_pair](#input\_ec2\_key\_pair) | The key name to use for the instance | `string` | n/a | yes |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | The list of rules for egress traffic. Required fields for each rule are 'protocol', 'from\_port', 'to\_port', and at least one of 'cidr\_blocks', 'ipv6\_cidr\_blocks', 'security\_groups', 'self', or 'prefix\_list\_sg'. Optional fields are 'description' and those not used from the previous list | <pre>map(object({<br/>    cidr_ipv4                    = optional(string, null)<br/>    cidr_ipv6                    = optional(string, null)<br/>    description                  = optional(string, "Managed by Terraform")<br/>    from_port                    = optional(string, null)<br/>    ip_protocol                  = optional(string, null)<br/>    prefix_list_id               = optional(string, null)<br/>    referenced_security_group_id = optional(string, null)<br/>    to_port                      = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_get_password_data"></a> [get\_password\_data](#input\_get\_password\_data) | Whether or not to allow retrieval of the local admin password | `bool` | `false` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | a map of strings that contains global level tags | `map(string)` | n/a | yes |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | Whether the metadata service is available. Valid values include enabled or disabled | `string` | `"enabled"` | no |
| <a name="input_http_put_response_hop_limit"></a> [http\_put\_response\_hop\_limit](#input\_http\_put\_response\_hop\_limit) | Number of network hops to allow instance metadata.  This should be 2 or higher if using containers on instance and you want containers to access metadata. | `number` | `1` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | Whether or not the metadata service requires session tokens, required=IMDSv2, optional=IMDSv1 | `string` | `"required"` | no |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | A list of the iam policy ARNs to attach to the IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_profile"></a> [iam\_profile](#input\_iam\_profile) | A variable to attach an existing iam profile to the ec2 instance(s) created | `string` | `""` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | The list of rules for ingress traffic. Required fields for each rule are 'protocol', 'from\_port', 'to\_port', and at least one of 'cidr\_blocks', 'ipv6\_cidr\_blocks', 'security\_groups', 'self', or 'prefix\_list\_sg'. Optional fields are 'description' and those not used from the previous list | <pre>map(object({<br/>    cidr_ipv4                    = optional(string, null)<br/>    cidr_ipv6                    = optional(string, null)<br/>    description                  = optional(string, "Managed by Terraform")<br/>    from_port                    = optional(string, null)<br/>    ip_protocol                  = optional(string, null)<br/>    prefix_list_id               = optional(string, null)<br/>    referenced_security_group_id = optional(string, null)<br/>    to_port                      = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to launch | `number` | `1` | no |
| <a name="input_instance_metadata_tags"></a> [instance\_metadata\_tags](#input\_instance\_metadata\_tags) | Enables or disables access to instance tags from the instance metadata service. Valid values include enabled or disabled | `string` | `"enabled"` | no |
| <a name="input_keys_to_grant"></a> [keys\_to\_grant](#input\_keys\_to\_grant) | A list of kms keys to grant permissions to for the role created. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the ec2 instance | `string` | n/a | yes |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Single private IP for a single instance | `string` | `null` | no |
| <a name="input_private_ips"></a> [private\_ips](#input\_private\_ips) | List of private IPs for multiple instances | `list(string)` | `[]` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | The size of the root ebs volume on the ec2 instances created | `string` | n/a | yes |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | The type of the root ebs volume on the ec2 instances created | `string` | `"gp3"` | no |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | This overwrites the default generated description for the security group | `string` | `"Managed by Terraform"` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Whether or not source/destination check should be enabled for the primary network interface | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of the subnets to be used when provisioning ec2 instances.  If instance count is 1, only the first subnet will be used | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | A list of aws\_alb\_target\_group ARNs, for use with Application Load Balancing | `list(string)` | `[]` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The User Data script to run | `string` | `null` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | Can be used instead of user\_data to pass base64-encoded binary data directly. Use this instead of user\_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | When used in combination with user\_data or user\_data\_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set | `bool` | `null` | no |
| <a name="input_volume_delete_on_termination"></a> [volume\_delete\_on\_termination](#input\_volume\_delete\_on\_termination) | Whether to delete attached EBS volumes when their EC2 instance is terminated | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of the vpc where resources are being created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_profile"></a> [iam\_profile](#output\_iam\_profile) | The name of the iam profile created in the module |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The AWS IAM Role arn created |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The AWS IAM Role arn created |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The AWS Instance id created |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | The network interface ID for the AWS instance |
| <a name="output_primary_private_ip_addresses"></a> [primary\_private\_ip\_addresses](#output\_primary\_private\_ip\_addresses) | A list of the primary private IP addesses assigned to the ec2 instance |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | The id of the security group created |
| <a name="output_tags"></a> [tags](#output\_tags) | List of tags of instances |
<!-- END_TF_DOCS -->

## Contributing

[Start Here](CONTRIBUTING.md)

## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)

## Contact Us

[Coalfire](https://coalfire.com/)

### Copyright

© 2025 Coalfire Systems Inc.
