resource "aws_instance" "server" {
  
  #ami                    = "${data.aws_ami.nomad-mr.image_id}"
  ami = random_id.server.keepers.ami_id
  instance_type          = var.server_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.main[count.index].id
  vpc_security_group_ids = [aws_security_group.client_lb.id,aws_security_group.consul_nomad_ui_ingress.id, aws_security_group.ssh_ingress.id, aws_security_group.allow_all_internal.id]
  count                  = var.server_count
  #TODO
  associate_public_ip_address = true
  # instance tags
  # ConsulAutoJoin is necessary for nodes to automatically join the cluster
  tags = merge(
    {
      "Name" = "${var.name}-server-${count.index}"
    },
    {
      "ConsulAutoJoin" = "autojoin"
    },
    {
      "NomadType" = "server"
    }
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  user_data = templatefile("./modules/shared/data-scripts/user-data-server.sh", {
    server_count              = var.server_count
    region                    = var.region
    cloud_env                 = "aws"
    retry_join                = var.retry_join
    nomad_binary              = var.nomad_binary
    nomad_consul_token_id     = var.nomad_consul_token_id
    nomad_consul_token_secret = var.nomad_consul_token_secret
    nomad_license_path        = var.nomad_license_path
    consul_license_path       = var.consul_license_path
    datacenter                = var.region
    recursor                  = var.recursor
  })
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
}