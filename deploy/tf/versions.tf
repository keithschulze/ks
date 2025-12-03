terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.24.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}
