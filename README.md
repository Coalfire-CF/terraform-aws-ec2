# ACE-AWS-EC2

AWS EC2 general purpose module.

## v1.0.0 - 2022-11-17

### **Description**

- Terraform Version: >= 1.0
- Cloud(s) supported: Government/Commercial
- Product Version/License: N/A
- FedRAMP Compliance Support: General usage
- DoD Compliance Support: General usage
- Misc Framework Support:
- Launchpad validated version: 2.6

## Setup and usage

### Description

This module creates ec2, iam, and security group resources.

### User Data

```hcl-terraform
user_data = [
    {
      path = {
        folder_name = "linux",
        file_name   = "test.sh"
      }
      vars = {
        test-var1 = "test1",
        test-var2 = "test2"
      }
    },
    ...
  ]

```

### Multiple ENIs

In order to assign multiple ENIs to a single instance using this module, the "instance_count" variable must be set to 1.

### Security Groups

```hcl-terraform
cidr_security_group_rules = [
    {
      type        = ["ingress"],
      protocol    = ["tcp"],
      from_port   = ["22"],
      to_port     = ["22"],
      cidr_blocks = var.cidrs_for_remote_access
      description = ["test1"]
    },
    ...
  ]
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
  source = "../../../../modules/aws-coalfire-ec2"
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
  module_depends_on = [module.ad1.instance_id]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| ami | ID of AMI to use for the instance | `string` | n/a | yes |
| ec2\_instance\_type | The type of instance to start | `string` | n/a | yes |
| ec2\_key\_pair | The key name to use for the instance | `string` | n/a | yes |
| global\_tags | a map of strings that contains global level tags | `map(string)` | n/a | yes |
| name | The name of the ec2 instance | `string` | n/a | yes |
| regional\_tags | a map of strings that contains regional level tags | `map(string)` | n/a | yes |
| root\_volume\_size | The size of the root ebs volume on the ec2 instances created | `string` | n/a | yes |
| subnet\_ids | A list of the subnets to be used when provisioning ec2 instances.  If instance count is 1, only the first subnet will be used | `list(string)` | n/a | yes |
| vpc\_id | The id of the vpc where resources are being created | `string` | n/a | yes |
| additional\_security\_groups | A list of additional security groups to attach to the network interfaces | `list(string)` | `[]` | no |
| associate\_eip | Whether or not to associate an Elastic IP | `bool` | `false` | no |
| associate\_public\_ip | Whether or not to associate a public IP (not EIP) | `bool` | `false` | no |
| cidr\_security\_group\_rules | A list of maps that contain the details for multiple security group rules for cidr based rules | `list(map(any))` | `[]` | no |
| ebs\_block\_devices | A list of maps that contains 3 keys: device name, volume size, and volume type | `list(map(string))` | `[]` | no |
| ebs\_optimized | Whether or not the instance is ebs optimized | `bool` | `false` | no |
| eni\_per\_instance | The number of ENIs per ec2 instance | `number` | `1` | no |
| iam\_policies | A list of the iam policy ARNs to attach to the IAM role | `list(string)` | `[]` | no |
| instance\_count | Number of instances to launch | `number` | `1` | no |
| private\_ip | The private ip for the instance | `string` | `""` | no |
| root\_volume\_type | The type of the root ebs volume on the ec2 instances created (typically gp2) | `string` | `"gp2"` | no |
| sg\_security\_group\_rules | A list of maps that contain the details for multiple security group rules for cidr based rules | `list(map(any))` | `[]` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| user\_data | a list of maps that contain the path to the user data script (starting at the shellScript folder) and the variables for that script. | `list(map(any))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam\_profile | The name of the iam profile created in the module |
| instance\_id | The AWS Instance id created |
| sg\_id | The id of the security group created |

### **Issues**

Bug fixes and enhancements are managed, tracked, and discussed through the GitHub issues on this repository.

Issues should be flagged appropriately.

- Bug
- Enhancement
- Documentation
- Code

#### Bugs

Bugs are problems that exist with the technology or code that occur when expected behavior does not match implementation.
For example, spelling mistakes on a dashboard.

Use the Bug fix template to describe the issue and expected behaviors.

#### Enhancements

Updates and changes to the code to support additional functionality, new features or improve engineering or operations usage of the technology.
For example, adding a new widget to a dashboard to report on failed backups is enhancement.

Use the Enhancement issue template to request enhancements to the codebase. Enhancements should be improvements that are applicable to wide variety of clients and projects. One of updates for a specific project should be handled locally. If you are unsure if something qualifies for an enhancement contact the repository code owner.

#### Pull Requests

Code updates ideally are limited in scope to address one enhancement or bug fix per PR. The associated PR should be linked to the relevant issue.

#### Code Owners

- Primary Code owner: Christian Stano (@cstano)
- Backup Code owner: James Westbrook (@i-ate-a-vm)

The responsibility of the code owners is to approve and Merge PR's on the repository, and generally manage and direct issue discussions.

### **Repository Settings**

Settings that should be applied to repos

#### **Branch Protection**

##### **main Branch**

- Require a pull request before merging
- Require Approvals
- Dismiss stale pull requests approvals when new commits are pushed
- Require review from Code Owners

##### **other branches**

- add as needed

#### **GitHub Actions**

##### **Markdown Linter**

- Triggered by a Pull Request on the main branch
- Makes use of the markdown-lint.yml and the customrules.js files, and will lint the README.md file present in the project's Top Level Directory and create a comment on the Pull Request with its body as any markdown formatting errors that are found or if there are none, then it will output 'Markdown Valid' as the body of the comment
- The only change that may need to be made is if the README.md file is not in the Top Level Directory, then the file path value must be changed in markdown-lint.yml, line 21

##### **Checkov Scan**

- Triggered by a Pull Request on the main branch
- Makes use of the checkov.yml file, and will scan the Terraform code present in the directory for any security or compliance misconfigurations using graph-based scanning and will create a comment on the Pull Request with its body as the findings from the scan
- No changes truly need to be made

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=3.26 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=3.26 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.eip_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.this_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.iam_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_kms_grant.kms_key_grant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [aws_lb_target_group_attachment.target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_network_interface_attachment.eni_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.this_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [cloudinit_config.user_data](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_eni_ids"></a> [additional\_eni\_ids](#input\_additional\_eni\_ids) | This variable allows for an ec2 instance to have multiple ENIs.  Instance count must be set to 1 | `list(any)` | `[]` | no |
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | A list of additional security groups to attach to the network interfaces | `list(string)` | `[]` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `string` | n/a | yes |
| <a name="input_associate_eip"></a> [associate\_eip](#input\_associate\_eip) | Whether or not to associate an Elastic IP | `bool` | `false` | no |
| <a name="input_associate_public_ip"></a> [associate\_public\_ip](#input\_associate\_public\_ip) | Whether or not to associate a public IP (not EIP) | `bool` | `false` | no |
| <a name="input_cidr_group_rules"></a> [cidr\_group\_rules](#input\_cidr\_group\_rules) | A list of maps that contain the details for multiple security group rules for cidr based rules | `list(map(any))` | `[]` | no |
| <a name="input_cidr_security_group_rules"></a> [cidr\_security\_group\_rules](#input\_cidr\_security\_group\_rules) | A list of maps that contain the details for multiple security group rules for cidr based rules | `list(map(list(any)))` | `[]` | no |
| <a name="input_default_iam_policy"></a> [default\_iam\_policy](#input\_default\_iam\_policy) | default iam base policy | `string` | `""` | no |
| <a name="input_ebs_block_devices"></a> [ebs\_block\_devices](#input\_ebs\_block\_devices) | A list of maps that contains 3 keys: device name, volume size, and volume type | `list(map(string))` | `[]` | no |
| <a name="input_ebs_kms_key_arn"></a> [ebs\_kms\_key\_arn](#input\_ebs\_kms\_key\_arn) | The ARN of the KMS key to encrypt EBS volumes | `string` | n/a | yes |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Whether or not the instance is ebs optimized | `bool` | `false` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | The type of instance to start | `string` | n/a | yes |
| <a name="input_ec2_key_pair"></a> [ec2\_key\_pair](#input\_ec2\_key\_pair) | The key name to use for the instance | `string` | n/a | yes |
| <a name="input_eni_per_instance"></a> [eni\_per\_instance](#input\_eni\_per\_instance) | The number of ENIs per ec2 instance | `number` | `1` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | a map of strings that contains global level tags | `map(string)` | n/a | yes |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | A list of the iam policy ARNs to attach to the IAM role | `list(string)` | `[]` | no |
| <a name="input_iam_profile"></a> [iam\_profile](#input\_iam\_profile) | A variable to attach an existing iam profile to the ec2 instance(s) created | `string` | `""` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to launch | `number` | `1` | no |
| <a name="input_keys_to_grant"></a> [keys\_to\_grant](#input\_keys\_to\_grant) | A list of kms keys to grant permissions to for the role created. | `list(string)` | `[]` | no |
| <a name="input_local_exec_command"></a> [local\_exec\_command](#input\_local\_exec\_command) | The command to be passed to the local exec provisioner.  The main use case for this variable is to create time delays between resources that depend on each other (i.e. AD) | `string` | `"true"` | no |
| <a name="input_module_depends_on"></a> [module\_depends\_on](#input\_module\_depends\_on) | A variable to simulate the depends on feature that resources have | `any` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the ec2 instance | `string` | n/a | yes |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | The private ip for the instance | `string` | `null` | no |
| <a name="input_regional_tags"></a> [regional\_tags](#input\_regional\_tags) | a map of strings that contains regional level tags | `map(string)` | n/a | yes |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | The size of the root ebs volume on the ec2 instances created | `string` | n/a | yes |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | The type of the root ebs volume on the ec2 instances created | `string` | `"gp3"` | no |
| <a name="input_sg_security_group_rules"></a> [sg\_security\_group\_rules](#input\_sg\_security\_group\_rules) | A list of maps that contain the details for multiple security group rules for cidr based rules | `list(map(any))` | `[]` | no |
| <a name="input_simple_user_data"></a> [simple\_user\_data](#input\_simple\_user\_data) | Simple string for 1 liner user data | `string` | `""` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Whether or not source/destination check should be enabled for the primary network interface | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of the subnets to be used when provisioning ec2 instances.  If instance count is 1, only the first subnet will be used | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | A list of aws\_alb\_target\_group ARNs, for use with Application Load Balancing | `list(string)` | `[]` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | a list of maps that contain the path to the user data script (starting at the shellScript folder) and the variables for that script. | `list(map(any))` | `[]` | no |
| <a name="input_user_data_gzip"></a> [user\_data\_gzip](#input\_user\_data\_gzip) | Whether or not to gzip the user data for the instance | `bool` | `true` | no |
| <a name="input_volume_delete_on_termination"></a> [volume\_delete\_on\_termination](#input\_volume\_delete\_on\_termination) | Whether to delete attached EBS volumes when their EC2 instance is terminated | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of the vpc where resources are being created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_profile"></a> [iam\_profile](#output\_iam\_profile) | The name of the iam profile created in the module |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The AWS IAM Role arn created |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The AWS Instance id created |
| <a name="output_primary_private_ip_addresses"></a> [primary\_private\_ip\_addresses](#output\_primary\_private\_ip\_addresses) | A list of the primary private IP addesses assigned to the ec2 instance |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | The id of the security group created |
| <a name="output_tags"></a> [tags](#output\_tags) | List of tags of instances |
<!-- END_TF_DOCS -->