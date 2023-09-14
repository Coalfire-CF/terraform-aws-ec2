data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  owners = ["amazon"]
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr_prefix}.0.0/24"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "${var.vpc_cidr_prefix}.0.0/24"
}

module "ec2_test" {
  source = "../.."

  name = "ec2_module_test_instance"

  ami               = data.aws_ami.ami.id
  ec2_instance_type = "t2.micro"
  instance_count    = 2

  vpc_id = aws_vpc.main.id
  subnet_ids = [aws_subnet.main.id]

  ec2_key_pair    = "ec2-module-test"
  ebs_kms_key_arn = aws_kms_key.ebs_key.arn

  # Storage
  root_volume_size = "20"

  # Security Group Rules
  ingress_rules = [{
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = [aws_vpc.main.cidr_block]
    },
    {
      protocol    = "tcp"
      from_port   = "22"
      to_port     = "22"
      cidr_blocks = [aws_vpc.main.cidr_block]
  }]

  egress_rules = [{
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
  }]

  # Tagging
  global_tags = {}
}