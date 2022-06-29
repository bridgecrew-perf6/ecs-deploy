# AWS provider version definition
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = var.project-tags
  }
}

# Create a VPC
module "vpc" {
  source      = "./modules/vpc"
  name-prefix = var.name-prefix
  aws_region  = var.aws_region
}

# Create an API running on an ECS Cluster
module "ecs" {
  source         = "./modules/ecs"
  aws_region     = var.aws_region
  aws_profile    = var.aws_profile
  name-prefix    = var.name-prefix
  vpc_id         = module.vpc.vpc_id
  public_subnet  = module.vpc.public_subnet
  private_subnet = module.vpc.private_subnet
}