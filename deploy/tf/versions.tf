terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}
