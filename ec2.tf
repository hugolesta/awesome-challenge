resource "aws_iam_instance_profile" "iam_profile" {
  name = "${var.env["prefix"]}-${var.env["role"]}-${replace(uuid(), "-", "")}"
  role = aws_iam_role.iam_role.id

  lifecycle {
    ignore_changes = [name]
  }
}

data "template_file" "aws_iam_role_tpl" {
  template = file("${path.module}/templates/aws_iam_role.tpl")
}

data "template_file" "aws_iam_role_policy_tpl" {
  template = file("${path.module}/templates/aws_iam_role_policy.tpl")
}

resource "aws_iam_role" "iam_role" {
  name_prefix        = "${var.env["project"]}-${var.env["environment"]}-"
  assume_role_policy = data.template_file.aws_iam_role_tpl.rendered
}

resource "aws_iam_role_policy" "ec2_default_role" {
  name   = "${var.env["project"]}-${var.env["environment"]}-ec2DefaultRole"
  role   = aws_iam_role.iam_role.id
  policy = data.template_file.aws_iam_role_policy_tpl.rendered
}


data "aws_ami" "linux_ami" {
  most_recent = "true"
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????.?-x86_64-gp2"]
  }
}

# Cloud init bootstrapping.

data "template_file" "cloud_init" {
  template = file(
    "${path.module}/templates/ec2_bootstrap.tpl"
  )

  vars = {
    additional_user_data = join("\n", [data.template_file.ssm_tunnel_instance.rendered, data.template_file.apache_installer.rendered])
    prefix               = var.env["prefix"]
    role                 = var.env["role"]
  }
}


data "template_file" "ssm_policy" {
  template = file("./templates/ssm_policy.tpl")
}

data "template_file" "ssm_tunnel_instance" {
  template = file("./templates/ssm_tunnel.tpl")
}

data "template_file" "apache_installer" {
  template = file("./templates/install_apache.tpl")
  vars = {
    REGION = var.env["region"]
  }
}


resource "aws_security_group" "ec2_sg" {
  name        = "${var.env["project"]}-${var.env["environment"]}-ec2"
  vpc_id      = module.vpc.vpc_id
  description = "${var.env["role"]} EC2 Instances Service SG"
  tags = merge(
    local.tags,
    {
      "Name" = "${var.env["project"]}-${var.env["environment"]}-ec2"
    },
  )
}

resource "aws_security_group_rule" "ec2_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "allow_http_incoming_traffic" {
  type              = "ingress"
  protocol          = "TCP"
  from_port         = 80
  to_port           = 80
  self              = true
  security_group_id = module.awesome_challenge_alb.security_group_id
}


resource "aws_launch_configuration" "launch_config" {
  name_prefix          = "${var.env["project"]}-${var.env["environment"]}-"
  image_id             = data.aws_ami.linux_ami.image_id
  instance_type        = var.launch_config_instance_type
  iam_instance_profile = aws_iam_instance_profile.iam_profile.name
  security_groups      = concat([aws_security_group.ec2_sg.id, module.awesome_challenge_alb.security_group_id], var.additional_sg_ids)
  user_data            = data.template_file.cloud_init.rendered
  enable_monitoring    = var.launch_config_enable_monitoring

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      iam_instance_profile,
    ]
  }

  root_block_device {
    volume_type           = var.root_block_device["volume_type"]
    volume_size           = var.root_block_device["volume_size"]
    delete_on_termination = var.root_block_device["delete_on_termination"]
    encrypted             = var.root_block_device["encrypted"]
  }
}


resource "aws_iam_role_policy" "ec2_instance_ssm_management" {
  name = "ec2SsmManagement"
  role = aws_iam_role.iam_role.id

  policy = data.template_file.ssm_policy.rendered
}


# ASG

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "${var.env["project"]}-${var.env["environment"]}-asg"
  min_size                  = var.asg_config["asg_min_size"]
  max_size                  = var.asg_config["asg_max_size"]
  desired_capacity          = var.asg_config["asg_desired_capacity"]
  vpc_zone_identifier       = module.subnets.private_subnet_ids
  launch_configuration      = aws_launch_configuration.launch_config.name
  health_check_grace_period = var.asg_config["asg_health_check_grace_period"]
  health_check_type         = var.asg_config["asg_health_check_type"]

  target_group_arns = [module.awesome_challenge_alb.default_target_group_arn]

  depends_on = [aws_launch_configuration.launch_config]

  lifecycle {
    ignore_changes = [
      name,
    ]
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = var.asg_tag_names
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "web_scale_in" {
  name                   = "${var.env["project"]}-${var.env["environment"]}-scale-in"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

resource "aws_autoscaling_policy" "web_scale_out" {
  name                   = "${var.env["project"]}-${var.env["environment"]}-scale-out"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}


resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_scale_in" {
  alarm_name                = "${var.env["project"]}-${var.env["environment"]}-scale-in"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
  alarm_actions = [aws_autoscaling_policy.web_scale_in.arn]
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_scale_our" {
  alarm_name                = "${var.env["project"]}-${var.env["environment"]}-scale-out"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "60"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
  alarm_actions = [aws_autoscaling_policy.web_scale_out.arn]
}
