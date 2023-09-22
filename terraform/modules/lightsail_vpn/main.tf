resource "aws_lightsail_instance" "f1tv_vpn" {
  count             = var.instance_count
  
  name              = var.instance_name
  availability_zone = var.availability_zone
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "nano_3_0"
  key_pair_name     = "key"
  user_data         = templatefile("${path.module}/user_data.sh", {
    tailscale_api_key = var.tailscale_api_key,
    name = var.instance_name
    }
  )
  tags = {
    "f1tv" = ""
  }
}

resource "aws_lightsail_instance_public_ports" "tailscale" {
  count         = length(aws_lightsail_instance.f1tv_vpn)
  instance_name = aws_lightsail_instance.f1tv_vpn[count.index].name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }

  port_info {
    protocol  = "udp"
    from_port = 41641
    to_port   = 41641
  }
}