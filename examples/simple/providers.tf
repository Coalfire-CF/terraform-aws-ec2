terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.15.0 < 6.0"
    }
  }
}

provider "aws" {
  region            = var.aws_region
  profile           = var.profile
  use_fips_endpoint = true
}