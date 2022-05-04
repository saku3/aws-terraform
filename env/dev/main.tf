terraform {
  backend "s3" {
    bucket = ""
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }

  required_providers {
    aws = {
      version = "~> 4.00"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Name = var.project
    }
  }
}
