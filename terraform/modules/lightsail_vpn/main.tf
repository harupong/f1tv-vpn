
resource "aws_lightsail_instance" "f1tv_vpn" {
  count = var.instance_count
  name  = var.instance_name
  # availability_zone = random_shuffle.shuffled_az.result[count.index]
  availability_zone = var.availability_zone
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "nano_3_0"
  key_pair_name     = "key"
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