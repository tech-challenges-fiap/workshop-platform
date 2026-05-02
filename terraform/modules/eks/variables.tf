variable "name_prefix" {
  description = "Prefix used for EKS resource names."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version used by EKS."
  type        = string
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS API endpoint is reachable from inside the VPC."
  type        = bool
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is reachable publicly."
  type        = bool
}

variable "vpc_id" {
  description = "VPC identifier used by EKS."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet identifiers available to the EKS control plane."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet identifiers available to the EKS control plane."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnet identifiers used by the managed node group."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types used by the managed node group."
  type        = list(string)
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
}
