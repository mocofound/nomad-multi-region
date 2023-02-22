#https://www.devopsschool.com/blog/terraform-variable-map-type-explained/

terraform {
  required_version = ">= 0.12.29, < 2.0"
  required_providers {
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.1"
    # }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
            configuration_aliases = [ aws.region1 , aws.region2 ]
    }
  }
}

provider "aws" {
  #alias = "region1"
  #region = var.region_1
  region = var.region_1
}

provider "aws" {
  alias = "region2"
  region = var.region_2
}