terraform {
  backend "s3" {
    bucket = "terraform-f1tv-vpn-us-east-2"
    key    = "state/terraform.tfstate"
    region = "us-east-2"
  }
}