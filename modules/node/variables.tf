variable "name" {
  type        = string
  description = "The name of the node."
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for the instance."
}

variable "key_name" {
  type        = string
  description = "Key name of the Key Pair to use for the instance."
}

variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate with."
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC."
  default     = true
}

variable "private_ip" {
  type        = string
  description = "Private IP address to associate with the instance in a VPC."
}

variable "volume_type" {
  type        = string
  description = "Type of volume."
  default     = "gp3"
}

variable "volume_size" {
  type        = number
  description = "Size of the volume in gibibytes (GiB)."
  default     = 50
}
