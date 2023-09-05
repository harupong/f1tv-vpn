terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "terraform-f1tv-vpn"
    key    = "state/terraform.tfstate"
    region = "us-west-2"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#https://stackoverflow.com/questions/63551694/creating-a-random-instance-with-terraform-autocreate-valid-configurations
# `terraform apply -target=random_shuffle.shuffled_az` must be run before `terraform apply` to generate the random order
# resource "random_shuffle" "shuffled_az" {
#   input        = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
#   result_count = 4
# }

resource "aws_lightsail_instance" "f1tv_vpn" {
  count = var.instance_count
  name  = "f1tv-main${count.index}-portland"
  # availability_zone = random_shuffle.shuffled_az.result[count.index]
  availability_zone = "us-west-2a"
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "nano_3_0"
  tags = {
    "f1tv" = ""
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip_address
      private_key = file("${var.lightsail_key_pair_path}")
    }

    inline = [
      "sudo hostnamectl set-hostname ${self.name}",
      "curl -fsSL https://tailscale.com/install.sh | sh",
      "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p /etc/sysctl.conf",
      "sudo tailscale up --authkey ${var.tailscale_api_key} --advertise-exit-node --ssh"
    ]
  }
}