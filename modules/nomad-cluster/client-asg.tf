locals {
  common_tags = {
    Name   = "${var.name}-client-${random_id.server.hex}"
    ConsulAutoJoin = "auto-join"
    NomadType = "client"
  }
  #ami_id = "${data.hcp_packer_image.nomad-multi-region.cloud_image_id}"
  #ami_id = "${data.aws_ami.nomad-mr.image_id}"
}



resource "aws_launch_template" "nomad_client" {
  name_prefix            = "${var.name}-${random_id.server.hex}-client"
  image_id               = random_id.server.keepers.ami_id
  #image_id               = "ami-027bc59ba19af5be9"
  instance_type          = var.client_instance_type
  key_name               = var.key_name
  #vpc_security_group_ids = [aws_security_group.nomad_client_nlb.id, aws_security_group.consul_nomad_ui_ingress.id, aws_security_group.ssh_ingress.id, aws_security_group.clients_ingress.id, aws_security_group.allow_all_internal.id, aws_security_group.client_lb.id]
  vpc_security_group_ids = [aws_security_group.nomad_client_nlb.id, aws_security_group.ssh_ingress.id, aws_security_group.clients_ingress.id, aws_security_group.allow_all_internal.id]
  
  user_data              = base64encode(templatefile(
    "./modules/shared/data-scripts/user-data-client.sh", {
      region        = var.region
      cloud_env                 = "aws"
      retry_join    = var.retry_join
      #consul_binary = var.consul_binary
      nomad_binary  = var.nomad_binary
      node_class    = "hashistack"
      nomad_license_path        = var.nomad_license_path
      consul_license_path       = var.consul_license_path
      nomad_consul_token_secret = var.nomad_consul_token_secret
      datacenter                = var.region
      recursor                  = var.recursor
    }))

  iam_instance_profile {
    #name = aws_iam_instance_profile.nomad_client.name
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        "Name" = "${var.name}-client"
      },
      {
        "ConsulAutoJoin" = "autojoin"
      },
      {
        "NomadType" = "client"
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

resource "aws_autoscaling_group" "nomad_client" {
  name               = "${var.name}-${random_id.server.hex}-client"
  #availability_zones = toset(data.aws_availability_zones.available.names)
  vpc_zone_identifier = toset(aws_subnet.private[*].id)
  #vpc_zone_identifier = ["${aws_subnet.private[0].id}"]
  desired_capacity   = var.asg_client_count
  min_size           = 0
  max_size           = 20
  force_delete = true
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
    create_before_destroy = false
    #ignore_changes = [target_group_arns]
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
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  launch_template {
    id      = aws_launch_template.nomad_client.id
    version = "$Latest"

  }
  tag {
    key                 = "Name"
    value               = "${var.name}-client-${random_id.server.hex}-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "NomadType"
    value               = "client"
    propagate_at_launch = true
  }
  tag {
      key = "boundary"
      value = "ssh"
      propagate_at_launch = true
    }

  # tag {
  #   key                 = "ConsulAutoJoin"
  #   value               = "autojoin"
  #   propagate_at_launch = true
  #}

}

resource "aws_iam_instance_profile" "nomad_client" {
  name_prefix = var.name
  role        = aws_iam_role.nomad_client.name
}

resource "aws_iam_role" "nomad_client" {
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.nomad_client_assume.json
}

resource "aws_iam_role_policy" "nomad_client" {
  name   = "nomad-client"
  role   = aws_iam_role.nomad_client.id
  policy = data.aws_iam_policy_document.nomad_client.json
}

data "aws_iam_policy_document" "nomad_client_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "nomad_client" {
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

