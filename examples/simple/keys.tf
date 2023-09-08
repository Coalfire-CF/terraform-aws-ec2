# Requires a .pem file exists in this directory. This should be a generated key-pair (example in README)
data "local_file" "key" {
  filename = "${var.key_name}.pem"
}

resource "aws_ssm_parameter" "ec2_module_key_parameter" {
  name        = "/test/${var.key_name}.pem"
  description = "Private key for EC2 module test build"
  type        = "SecureString"
  value       = data.local_file.key.content
}

resource "aws_kms_key" "ebs_key" {
  description         = "ebs key for ec2-module"
  policy              = data.aws_iam_policy_document.ebs_key.json
  enable_key_rotation = true
}

locals {
  partition = strcontains(var.aws_region, "gov") ? "aws-gov" : "aws"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ebs_key" {
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:${local.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
}
