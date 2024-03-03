variable "prefix" {
  type        = string
  description = "The prefix to append to the name of resources."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "ingress_access_cidr" {
  type        = string
  description = "The IP address range allowed access to the cluster."
}
