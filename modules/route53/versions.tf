terraform {
  required_version = ">= 0.12.29, < 2.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
      #configuration_aliases = [ aws.region2 ]
    }
  }
}

# provider "aws" {
#   region = var.region
# }
