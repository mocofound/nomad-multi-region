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