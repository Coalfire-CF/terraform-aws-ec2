# ACE-AWS-EC2

AWS EC2 general purpose module.

## v1.0.0 - 2022-11-17

### **Description**

- Terraform Version: >= 1.0
- Cloud(s) supported: Government/Commercial
- Product Version/License: 
- FedRAMP Compliance Support: General usage
- DoD Compliance Support: General usage
- Misc Framework Support:
- Launchpad validated version: 2.6

# **Setup and usage**

## Description
This module creates ec2, iam, and security group resources.

## User Data
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

## Multiple ENIs
In order to assign mulitple ENIs to a single instance using this module, the "instance_count" variable must be set to 1.



## Security Groups
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
## IAM
```hcl-terraform
iam_policies      = [aws_iam_policy.test_policy_1.arn, ...]

```

## Multiple EBS Volumes
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


## Attaching Security Groups or IAM Profile from other instances
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

#### **Code Location**

Code should be stored in terraform/app/code

#### **Code updates**

Ensure that vars zyx are in regional/global vars

### **Issues**

Bug fixes and enhancements are managed, tracked, and discussed through the GitHub issues on this repository.

Issues should be flagged appropriately.

- Bug
- Enhancement
- Documentation
- Code

#### **Bugs**

Bugs are problems that exist with the technology or code that occur when expected behavior does not match implementation.
For example, spelling mistakes on a dashboard.

Use the Bug fix template to describe the issue and expected behaviors.

#### **Enhancements**

Updates and changes to the code to support additional functionality, new features or improve engineering or operations usage of the technology.
For example, adding a new widget to a dashboard to report on failed backups is enhancement.

Use the Enhancement issue template to request enhancements to the codebase. Enhancements should be improvements that are applicable to wide variety of clients and projects. One of updates for a specific project should be handled locally. If you are unsure if something qualifies for an enhancement contact the repository code owner.

#### **Pull Requests**

Code updates ideally are limited in scope to address one enhancement or bug fix per PR. The associated PR should be linked to the relevant issue.

#### **Code Owners**

- Primary Code owner: Douglas Francis (@douglas-f)
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
