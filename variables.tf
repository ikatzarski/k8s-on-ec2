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
  default     = "172.31.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The Public Subnet CIDR block."
  default     = "172.31.1.0/24"
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for the instance."
  default     = "t3.medium"
}

variable "control_plane_private_ip" {
  type        = string
  description = "Private IP of the Control Plane."
  default     = "172.31.1.10"
}

variable "worker_suffixes" {
  type        = list(string)
  description = "The suffix appended to worker names and IPs."
  default     = ["20", "21"]
}

variable "worker_private_ip_start" {
  type        = string
  description = "The beginning of each worker's private IP."
  default     = "172.31.1."
}

variable "ingress_access_cidr" {
  type        = string
  description = "The IP address range allowed access to the cluster."
}
