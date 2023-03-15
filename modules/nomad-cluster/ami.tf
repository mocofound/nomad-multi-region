locals {
  ami_id = var.use_hcp_packer == true ? "${data.hcp_packer_image.nomad-multi-region.cloud_image_id}" : "${data.aws_ami.nomad-mr.image_id}"
  #ami_id = "${data.aws_ami.nomad-mr.image_id}"
}

resource "random_id" "server" {
  byte_length = 4
  keepers = {
    ami_id = local.ami_id
    #"ami_id" = "${data.aws_ami.nomad-mr.image_id}"
  }
}

resource "random_id" "random" {
  byte_length = 4
  keepers = {
    "ami_id" = "${data.aws_ami.nomad-mr.image_id}"
  }
}

data "aws_ami" "nomad-mr" {
  #executable_users = ["self"]
  most_recent      = true
  #name_regex       = "^hashistack-\\d{3}"
  owners           = ["self","099720109477"]

  filter {
    name   = "name"
    values = ["nomad-mr-*"]
  }
}

data "hcp_packer_image" "nomad-multi-region" {
  #bucket_name     = "nomad-multi-region-focal"
  bucket_name     = "nomad-multi-region"
  channel         = "security-approved"
  cloud_provider  = "aws"
  region          = var.region
}

#Then replace your existing references with
# data.hcp_packer_image.nomad-multi-region.cloud_image_id
