resource "aws_iam_role" "this_role" {
  count = length(var.iam_policies) > 0 ? 1 : 0
  name = "${var.name}_role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "iam_policy_attach" {
  count      = length(var.iam_policies)
  policy_arn = var.iam_policies[count.index]
  role       = aws_iam_role.this_role[0].name
}

#resource "aws_iam_role_policy_attachment" "iam_policy_attach_base" {
#  policy_arn = var.default_iam_policy
#  role       = aws_iam_role.this_role[0].name
#}

resource "aws_iam_instance_profile" "this_profile" {
  count = length(var.iam_policies) > 0 ? 1 : 0
  name = "${var.name}_profile"
  role = aws_iam_role.this_role[0].name
}

resource "aws_kms_grant" "kms_key_grant" {
  count = length(var.keys_to_grant)
  name              = "${var.name}-grant-${count.index}"
  key_id            = var.keys_to_grant[count.index]
  grantee_principal = aws_iam_role.this_role[0].arn
  operations = [
    "Encrypt",
    "Decrypt",
  "DescribeKey"]
}
