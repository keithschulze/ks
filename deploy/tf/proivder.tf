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
