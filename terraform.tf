# If the running Terraform version doesn't meet these constraints,
# an error is shown
terraform {
  required_version = ">= 0.12.0, <= 0.14.4"
  # Uncomment this and replace it with your configuration to enable
  # the Terraform S3 backend configuration.
  #   backend "s3" {
  #     region = "us-east-1"
  #     bucket = "terraform-awesome-challenge-tfstate"
  #     key    = "awesome/sdx/terraform.tfstate"
  #   }
}
