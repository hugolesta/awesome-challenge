env = {
  name           = "awesome-challenge"
  prefix         = "sdx"
  role           = "ec2"
  delimiter      = "-"
  region         = "us-east-1"
  key_name       = "sandbox"
  environment    = "sdx"
  tagVersion     = "0.0.1"
  project        = "awesome-challenge"
  owner          = "hlesta@icloud.com"
  costCenter     = "DevOpsEng"
  expirationDate = "01/01/2022"
}

vpc = {
  cidr_block = "10.101.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b"]
}

root_block_device = {
  volume_type           = "gp2"
  volume_size           = 8
  delete_on_termination = true
  encrypted             = true
}

asg_config = {
  asg_min_size = "1"
  asg_max_size = "3"
  asg_desired_capacity = "3"
  asg_health_check_grace_period = 300
  asg_health_check_type = "EC2"
}

asg_tag_names = {
  Name = "awesome-project-asg"
}