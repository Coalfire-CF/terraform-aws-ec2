provider "aws" {
  region                 = var.aws_region
  skip_region_validation = true
  profile                = var.profile
  use_fips_endpoint      = true

  default_tags {
    tags = {
      Application = "This is a test"
      Owner       = "Coalfire"
      Team        = "AWS Native Architecture PAK Team"
      Environment = "dev"
    }
  }
}
