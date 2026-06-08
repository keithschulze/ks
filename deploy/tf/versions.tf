terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.49.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}
