variable "env" {
  description = "Map containing all the environment configuration"
  type        = map(string)
  default = {
    name           = ""
    prefix         = ""
    environment    = "sandbox"
    role           = "ec2"
    delimiter      = "-"
    owner          = "hlesta@icloud.com"
    tagVersion     = "1"
    region         = "us-east-1"
    key_name       = "default"
    project        = "default"
    costCenter     = "DevOpsEng"
    owner          = "default"
    expirationDate = "01/01/2022"
  }
}

variable "vpc" {
  description = "Map containing all attributes of the VPC"
}


variable "additional_user_data" {
  description = "Contains additional code (BASH Snippet) to append into the cloud-init template"
  default     = ""
}

variable "additional_sg_ids" {
  type        = list(string)
  default     = []
  description = "(optional) Aditional sg id"
}

# Launch Configuration

variable "launch_config_instance_type" {
  description = "The size of instance to launch"
  default     = "t2.micro"
}
variable "launch_config_enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  default     = false
}

variable "root_block_device" {
  description = "Config you need to setup the root block device"
  type        = map(string)
  default     = {}
}


variable "asg_config" {
  description = "Config you need to setup the autoscaling group"
  type        = map(string)
}

variable "asg_tag_names" {
  description = "A mapping of tag names to assign to the ASG resource. Should match the naming of the keys in tags variable"
  type        = map(string)
}
