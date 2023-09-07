terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "lightsail_vpn" {
  source = "../../modules/lightsail_vpn"

  count                   = var.instance_count
  instance_name           = "f1tv-main${count.index}-columbus"
  availability_zone       = var.aws_availability_zone
  lightsail_key_pair_path = var.lightsail_key_pair_path
  tailscale_api_key       = var.tailscale_api_key
}

#https://stackoverflow.com/questions/63551694/creating-a-random-instance-with-terraform-autocreate-valid-configurations
# `terraform apply -target=random_shuffle.shuffled_az` must be run before `terraform apply` to generate the random order
# resource "random_shuffle" "shuffled_az" {
#   input        = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
#   result_count = 4
# }
