variable "name_prefix" {
  description = "Prefix used for network resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block allocated to the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones used by the VPC."
  type        = number
}

variable "enable_nat_gateway" {
  description = "Whether private subnets receive internet egress through a NAT gateway."
  type        = bool
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
}
