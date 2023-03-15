# resource "aws_instance" "server" {
#   count                  = var.server_count
#   #ami                    = "${data.aws_ami.nomad-mr.image_id}"
#   ami = random_id.server.keepers.ami_id
#   instance_type          = var.server_instance_type
#   key_name               = var.key_name
#   subnet_id              = aws_subnet.public[count.index].id
#   #subnet_id              = aws_subnet.private[count.index].id
#   vpc_security_group_ids = [aws_security_group.vault_server_nlb.id,aws_security_group.consul_nomad_ui_ingress.id, aws_security_group.ssh_ingress.id, aws_security_group.allow_all_internal.id]

#   #TODO
#   associate_public_ip_address = true
#   tags = merge(
#     {
#       "Name" = "${var.name}-server-${count.index}"
#     },
#     {
#       "ConsulAutoJoin" = "autojoin"
#     },
#     {
#       "NomadType" = "server"
#     },
#     {
#       "boundary" = "ssh"
#     }
#   )

#   root_block_device {
#     volume_type           = "gp2"
#     volume_size           = var.root_block_device_size
#     delete_on_termination = "true"
#     tags = {}
#   }

#   user_data = templatefile("./modules/shared/data-scripts/user-data-server.sh", {
#     server_count              = var.server_count
#     region                    = var.region
#     cloud_env                 = "aws"
#     retry_join                = var.retry_join
#     nomad_binary              = var.nomad_binary
#     nomad_consul_token_id     = var.nomad_consul_token_id
#     nomad_consul_token_secret = var.nomad_consul_token_secret
#     nomad_license_path        = var.nomad_license_path
#     consul_license_path       = var.consul_license_path
#     datacenter                = var.region
#     recursor                  = var.recursor
#     vault_license_path        = var.vault_license_path
#     kms_key                   = aws_kms_key.vault.id
#   })
#   iam_instance_profile = aws_iam_instance_profile.instance_profile.name

#   metadata_options {
#     http_endpoint          = "enabled"
#     instance_metadata_tags = "enabled"
#   }
#   depends_on = [
#     aws_kms_key.vault
#   ]
# }



locals {
#   common_tags = {
#     Name   = "${var.name}-vault-${random_id.server.hex}"
#     AutoJoin = "vault"
#     NomadType = "server"
#     boundary  = "ssh"
#   }
  #ami_id = "${data.hcp_packer_image.nomad-multi-region.cloud_image_id}"
  #ami_id = "${data.aws_ami.nomad-mr.image_id}"
}



resource "aws_launch_template" "vault_server" {
  name_prefix            = "${var.name}-${random_id.server.hex}-vault-server"
  image_id               = random_id.server.keepers.ami_id
  #image_id               = "ami-027bc59ba19af5be9"
  instance_type          = var.server_instance_type
  key_name               = var.key_name
  #vpc_security_group_ids = [aws_security_group.vault_server_nlb.id, aws_security_group.consul_nomad_ui_ingress.id, aws_security_group.ssh_ingress.id, aws_security_group.clients_ingress.id, aws_security_group.allow_all_internal.id, aws_security_group.client_lb.id]
  #vpc_security_group_ids = [aws_security_group.nomad_client_nlb.id, aws_security_group.ssh_ingress.id, aws_security_group.clients_ingress.id, aws_security_group.allow_all_internal.id]
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.nomad_client_nlb.id,aws_security_group.consul_nomad_ui_ingress.id, aws_security_group.ssh_ingress.id, aws_security_group.allow_all_internal.id]
  }
  user_data              = base64encode(templatefile(
    "./modules/shared/data-scripts/user-data-server-vault.sh", {
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
    }))

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        "Name" = "${var.name}-vault-server"
      },
      {
        "AutoJoin" = "autojoin"
      },
      {
        "NomadType" = "server"
      }
  )
  }
  block_device_mappings {
    device_name = "/dev/xvdd"
    ebs {
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = "true"
    }
  }
  depends_on             = [aws_instance.server[0]]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "vault_server" {
  name               = "${var.name}-${random_id.server.hex}-server"
  vpc_zone_identifier = toset(aws_subnet.public[*].id)
  desired_capacity   = var.asg_server_count
  min_size           = 0
  max_size           = 20
  force_delete = true
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
    create_before_destroy = false
  }
  depends_on         = [
    aws_instance.server[0],
    aws_nat_gateway.public[0],
    aws_route_table_association.private[0],
    aws_route_table_association.public[0]
    ]
  load_balancers     = [aws_elb.nomad_client.name]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 1
    }
    triggers = ["tag"]
  }

  launch_template {
    id      = aws_launch_template.vault_server.id
    version = "$Latest"

  }
  tag {
    key                 = "Name"
    value               = "${var.name}-vault-${random_id.server.hex}-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "VaultType"
    value               = "server"
    propagate_at_launch = true
  }
  tag {
      key = "boundary"
      value = "ssh"
      propagate_at_launch = true
    }

  tag {
    key                 = "AutoJoin"
    value               = "autojoin"
    propagate_at_launch = true
  }

}

resource "aws_iam_instance_profile" "vault_server" {
  name_prefix = var.name
  role        = aws_iam_role.vault_server.name
}

resource "aws_iam_role" "vault_server" {
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.vault_server_assume.json
}

resource "aws_iam_role_policy" "vault_server" {
  name   = "vault-server"
  role   = aws_iam_role.vault_server.id
  policy = data.aws_iam_policy_document.vault_server.json
}

data "aws_iam_policy_document" "vault_server_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault_server" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]

    resources = ["*"]
  }
}