terraform {
  required_version = ">= 0.12.29, < 2.0"
  required_providers {
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.1"
    # }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 1.4.0"
    }
  }
}