terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.61.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}
