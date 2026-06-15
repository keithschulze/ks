terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.50.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}
