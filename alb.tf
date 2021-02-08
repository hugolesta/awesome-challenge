
module "awesome_challenge_alb" {
  source                           = "git::https://github.com/cloudposse/terraform-aws-alb.git?ref=tags/0.29.4"
  name                             = "${var.env["environment"]}-alb"
  vpc_id                           = module.vpc.vpc_id
  subnet_ids                       = module.subnets.public_subnet_ids
  https_enabled                    = false
  http_enabled                     = true
  target_group_port                = 80
  target_group_target_type         = "instance"
  internal                         = false
  health_check_path                = "/index.html"
  health_check_healthy_threshold   = 10
  health_check_unhealthy_threshold = 10
  health_check_timeout             = 120
  health_check_interval            = 300
  tags                             = local.tags
}


resource "aws_lb_listener_rule" "http_rule" {
  listener_arn = module.awesome_challenge_alb.http_listener_arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = module.awesome_challenge_alb.default_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
