locals { 
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "regions" {
  type = list(string)
  default = ["us-east-1", "us-east-2"]
}

variable "region" {
  type = string
  default = "us-east-1"
}

data "amazon-ami" "hashistack" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
    #name                               = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
    #name                               = "ubuntu/images/hvm-ssd/*ubuntu-focal-20.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = var.region
}


source "amazon-ebs" "hashistack" {
  ami_name      = "nomad-mr-${local.timestamp}"
  instance_type = "t2.medium"
  ami_regions = var.regions
  region        = var.region
  source_ami    = "${data.amazon-ami.hashistack.id}"
  ssh_username  = "ubuntu"
  force_deregister = true
  force_delete_snapshot = true
  
  tags = {
    Name        = "nomad-alb"
    source = "hashicorp/learn"
    purpose = "nomad-mr"
    OS_Version = "Ubuntu"
    Release = "Latest"
    Base_AMI_ID = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }
  
  snapshot_tags = {
    Name        = "nomad-alb"
    source = "hashicorp/learn"
    purpose = "demo"
  }
}

build {
  sources = ["source.amazon-ebs.hashistack"]

  provisioner "shell" {
    inline = ["sudo mkdir -p /ops/shared", "sudo chmod 777 -R /ops"]
  }

  provisioner "file" {
    destination = "/ops"
    source      = "../modules/shared"
  }

  provisioner "shell" {
    environment_vars = ["INSTALL_NVIDIA_DOCKER=false", "CLOUD_ENV=aws"]
    script           = "../modules/shared/scripts/setup.sh"
  }
  
  post-processor "manifest" {}

}
