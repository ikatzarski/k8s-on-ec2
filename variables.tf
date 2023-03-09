variable "project" {
  type        = string
  description = "The project name."
  default     = "k8s"
}

variable "environment" {
  type        = string
  description = "The environment name."
  default     = "dev"
}

variable "region" {
  type        = string
  description = "The region the infrastructure will be deployed in."
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The VPC CIDR block."
  default     = "10.0.0.0/16"
}

variable "pub_subnet_cidr" {
  type        = string
  description = "The Public Subnet CIDR block."
  default     = "10.0.1.0/24"
}

variable "ami" {
  type        = string
  description = "Ubuntu 22.04 LTS from 2023-03-03."
  default     = "ami-050096f31d010b533"
}

variable "instance_type" {
  type        = string
  description = "The instance type."
  default     = "t2.medium"
}

variable "volume_type" {
  type        = string
  description = "The volume type."
  default     = "gp2"
}

variable "volume_size" {
  type        = number
  description = "Size of the volume in gibibytes (GiB)."
  default     = 50
}

variable "control_plane_ingress_cidr" {
  type        = string
  description = "The IP addresses which can access the Control Plane."
}
