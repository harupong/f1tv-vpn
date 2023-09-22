#!/bin/bash

hostnamectl set-hostname ${name}
curl -fsSL https://tailscale.com/install.sh | sh
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
tailscale up --authkey ${tailscale_api_key} --advertise-exit-node --ssh