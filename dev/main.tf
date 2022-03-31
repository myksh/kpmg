terraform {
  backend "s3" {
    bucket = "mykshrtfbckend01"
    key    = "tf01.tfstate"
    region = "ap-southeast-2"
  }
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}
# Create an s3 bucket
resource "aws_s3_bucket" "mayanks281183bucket" {
  bucket = "mykshrtfbckend01"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = "true"
  }
}
module "dev_vpc" {
  source          = "../modules/vpc"
  /*vpc_cidr        = "192.168.0.0/16"
  tenancy         = "default"
  vpc_id          = module.dev_vpc.vpc_id
  subnet_cidr     = "192.168.1.0/24"
  subnet_cidr2    = "192.168.2.0/24"
  pub_subnet_cidr = "192.168.3.0/24" */
}
module "dev_ec2" {
  source      = "../modules/ec2"
  subnet_id   = module.dev_vpc.int_subnet_id
  rhel_ami_id = module.dev_ec2.rhel8_ami
  # ec2_count   = "1"
}