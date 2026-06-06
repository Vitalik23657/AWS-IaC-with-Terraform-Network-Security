variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "public_instance_id" {
  description = "ID of the public EC2 instance"
  type        = string
}

variable "private_instance_id" {
  description = "ID of the private EC2 instance"
  type        = string
}

variable "allowed_ip_range" {
  description = "List of CIDR blocks allowed to access the infrastructure"
  type        = list(string)
}

variable "project_id" {
  description = "Project identifier used for naming and tagging resources"
  type        = string
}