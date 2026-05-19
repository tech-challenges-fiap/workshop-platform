variable "project" {
  description = "Global challenge prefix."
  type        = string
  default     = "workshop"
}

variable "repo" {
  description = "Official repository slug."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Shared platform environment label used for resource names and tags."
  type        = string
  default     = "shared"

  validation {
    condition     = var.environment == "shared"
    error_message = "environment must be shared because stag and prod run as namespaces in one cluster."
  }
}

variable "resource_suffix" {
  description = "Identifier of the main EKS resource."
  type        = string
  default     = "cluster"
}

variable "aws_region" {
  description = "AWS region used by the provider and backend."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block allocated to the platform VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones used by public and private subnets."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "az_count must be at least 2."
  }
}

variable "enable_nat_gateway" {
  description = "Whether private subnets receive internet egress through a NAT gateway."
  type        = bool
  default     = false
}

variable "node_subnet_tier" {
  description = "Subnet tier used by EKS managed nodes. Use public for the lowest-cost profile without NAT, or private when NAT/VPC endpoints are available."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.node_subnet_tier)
    error_message = "node_subnet_tier must be public or private."
  }
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.33"
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS API endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is reachable publicly."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "EC2 instance types used by the managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 1

  validation {
    condition     = var.node_max_size >= var.node_min_size
    error_message = "node_max_size must be greater than or equal to node_min_size."
  }
}

variable "ingress_nginx_chart_version" {
  description = "ingress-nginx Helm chart version installed into the cluster."
  type        = string
  default     = "4.13.0"
}

variable "enable_datadog" {
  description = "Whether to install the Datadog Helm chart."
  type        = bool
  default     = false
}

variable "datadog_chart_version" {
  description = "Datadog Helm chart version installed into the cluster."
  type        = string
  default     = "3.128.0"
}

variable "datadog_api_key" {
  description = "Datadog API key used by the Helm chart when Datadog is enabled."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = !var.enable_datadog || var.datadog_api_key != null
    error_message = "datadog_api_key must be set when enable_datadog is true."
  }
}

variable "datadog_app_key" {
  description = "Datadog application key required by the Datadog provider to manage dashboards and monitors."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = !var.enable_datadog || var.datadog_app_key != null
    error_message = "datadog_app_key must be set when enable_datadog is true."
  }
}

variable "datadog_notification_targets" {
  description = "List of Datadog notification targets for monitors (e.g. @slack-channel, @user@email.com)."
  type        = list(string)
  default     = []
}
