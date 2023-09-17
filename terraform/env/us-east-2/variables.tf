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

variable "instance_count" {
  description = "number of Lightsail instances to launch. If not specified, 1 instance will be launched"
  default     = 1
  type        = number
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_availability_zone" {
  description = "AWS Availability Zone"
  type        = string
}

variable "instance_name_prefix" {
  description = "prefix for instance name"
  type        = string
}