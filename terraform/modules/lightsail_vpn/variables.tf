variable "instance_count" {
  description = "number of Lightsail instances to launch. If not specified, 1 instance will be launched"
  default     = 1
  type        = number
}

variable "instance_name" {
  description = "name of Lightsail instance"
  type        = string
}

variable "availability_zone" {
  description = "availability zone for Lightsail instance"
  type        = string
}

variable "tailscale_api_key" {
  description = "Tailscale API Key for ephemeral nodes, which expires in 180 days"
  type        = string
  sensitive   = true
}

variable "lightsail_key_pair_path" {
  description = "ssh key pair path for Lightsail instances"
  type        = string
  sensitive   = true
}