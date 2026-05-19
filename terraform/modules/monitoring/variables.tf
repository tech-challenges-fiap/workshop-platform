terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.52"
    }
  }
}

variable "enable" {
  description = "Whether to create monitoring resources."
  type        = bool
  default     = false
}

variable "service_name" {
  description = "Primary application service name."
  type        = string
  default     = "workshop-app"
}

variable "edge_service_name" {
  description = "Edge service name."
  type        = string
  default     = "workshop-edge"
}

variable "notification_targets" {
  description = "List of Datadog notification targets (e.g. @slack-channel, @email)."
  type        = list(string)
  default     = []
}
