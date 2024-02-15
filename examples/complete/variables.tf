variable "stage" {
  default     = "test"
  type        = string
  description = "The environment that this infrastrcuture is being deployed to e.g. dev, stage, or prod"
}

variable "namespace" {
  default     = "mp"
  type        = string
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "name" {
  default     = "ssm-agent"
  type        = string
  description = "The name section of the resulting service. i.e. Backend, Web, etc."
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "The AWS Region to deploy these resources to."
}

variable "availability_zones" {
  default     = ["us-east-1a"]
  type        = list(string)
  description = "List of Availability Zones where subnets will be created"
}

variable "nat_gateway_enabled" {
  default     = true
  type        = bool
  description = "Whether to enable NAT Gateways. If false, then the application uses NAT Instances, which are much cheaper."
}

variable "ipv6_enabled" {
  default     = true
  type        = bool
  description = "Whether to enable IPv6 addresses for subnets."
}
