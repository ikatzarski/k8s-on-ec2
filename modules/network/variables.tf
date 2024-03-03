variable "prefix" {
  type        = string
  description = "The prefix to append to the name of resources."
}

variable "vpc_cidr_block" {
  type        = string
  description = "The VPC CIDR block."
}

variable "public_subnet_cidr" {
  type        = string
  description = "The Public Subnet CIDR block."
}
