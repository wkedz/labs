terraform {
  required_version = ">=1.11.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.79.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}