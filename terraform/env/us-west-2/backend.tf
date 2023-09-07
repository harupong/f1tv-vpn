terraform {
  backend "s3" {
    bucket = "terraform-f1tv-vpn-us-west-2"
    key    = "state/terraform.tfstate"
    region = "us-west-2"
  }
}