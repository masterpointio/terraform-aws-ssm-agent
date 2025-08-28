variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "namespace" {
  type        = string
  description = "Namespace for resource naming"
  default     = "mp"
}

variable "stage" {
  type        = string
  description = "Stage for resource naming"
  default     = "test"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ipv6_enabled" {
  type        = bool
  description = "Enable IPv6"
  default     = false
}
