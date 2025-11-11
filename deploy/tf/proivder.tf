terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    encrypt = true
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Project     = var.app_name
      Environment = var.deploy_env
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  default_tags {
    tags = {
      Project     = var.app_name
      Environment = var.deploy_env
    }
  }
}
