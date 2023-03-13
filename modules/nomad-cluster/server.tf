resource "aws_instance" "server" {
  count                  = var.server_count
  #ami                    = "${data.aws_ami.nomad-mr.image_id}"
  ami = random_id.server.keepers.ami_id
  instance_type          = var.server_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index].id
  #subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.nomad_client_nlb.id,aws_security_group.consul_nomad_ui_ingress.id, aws_security_group.ssh_ingress.id, aws_security_group.allow_all_internal.id]

  #TODO
  associate_public_ip_address = true
  tags = merge(
    {
      "Name" = "${var.name}-server-${count.index}"
    },
    {
      "ConsulAutoJoin" = "autojoin"
    },
    {
      "NomadType" = "server"
    },
    {
      "boundary" = "ssh"
    }
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
    tags = {}
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
    vault_license_path        = var.vault_license_path
    kms_key                   = aws_kms_key.vault.id
  })
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
  depends_on = [
    aws_kms_key.vault
  ]
}

resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-kms-unseal-${var.name}"
  }
}