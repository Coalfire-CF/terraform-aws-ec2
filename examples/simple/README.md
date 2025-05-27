## EC2 module simple example

This example creates 2 EC2 instances using the EC2 module, along with a temporary VPC, subnet, and the keys required to test the module.

# Prerequisites

Generate an EC2 key pair and place the pem key in this directory. Add the pem file to the tfvars file. To match the example tfvars file, run the following command in the terminal while in this directory:

`aws ec2 create-key-pair --profile sandbox --region us-east-2 --key-type rsa --key-format pem --query "KeyMaterial" --key-name "ec2-module-test" --output text > ec2-module-test.pem`

Note that `terraform destroy` will NOT remove the key pair from the AWS account as it is not tracked by state.
