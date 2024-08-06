variable "vpc_id" {
  type        = string
  description = "The ID of the VPC which the EC2 Instance will run in."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The Subnet IDs which the SSM Agent will run in. These *should* be private subnets."
}

variable "permissions_boundary" {
  default     = ""
  type        = string
  description = "The ARN of the permissions boundary that will be applied to the SSM Agent role."
}

######################
## INSTANCE CONFIG ##
####################

variable "instance_type" {
  default     = "t4g.nano"
  type        = string
  description = "The instance type to use for the SSM Agent EC2 instance."
}

variable "ami" {
  default     = ""
  type        = string
  description = "The AMI to use for the SSM Agent EC2 Instance. If not provided, the latest Amazon Linux 2023 AMI will be used. Note: This will update periodically as AWS releases updates to their AL2023 AMI. Pin to a specific AMI if you would like to avoid these updates."
}

variable "architecture" {
  description = "The architecture of the AMI (e.g., x86_64, arm64)"
  type        = string
  default     = "arm64"
}

variable "user_data" {
  default     = <<EOT
#!/bin/bash
# NOTE: Since we're using a latest Amazon Linux AMI, we shouldn't need this,
# but we'll update it to be sure.
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
EOT
  type        = string
  description = "The user_data to use for the SSM Agent EC2 instance. You can use this to automate installation of psql or other required command line tools."
}

variable "key_pair_name" {
  default     = null
  type        = string
  description = "The name of the key-pair to associate with the SSM Agent instances. This can be (and probably should) left empty unless you specifically plan to use `AWS-StartSSHSession`."
}

variable "additional_security_group_ids" {
  description = "Security groups that will be attached to the app instances"
  type        = list(string)
  default     = []
}

variable "monitoring_enabled" {
  description = "Enable detailed monitoring of instance"
  type        = bool
  default     = true
}

variable "associate_public_ip_address" {
  description = "Associate public IP address"
  type        = bool
  # default should fall back to subnet setting
  default = null
}

variable "metadata_http_endpoint_enabled" {
  description = "Whether or not to enable the metadata http endpoint"
  type        = bool
  default     = true
}

variable "metadata_imdsv2_enabled" {
  description = <<-EOT
    Whether or not the metadata service requires session tokens,
    also referred to as Instance Metadata Service Version 2 (IMDSv2).
  EOT
  type        = bool
  default     = true
}

variable "metadata_http_protocol_ipv6_enabled" {
  description = "Enable IPv6 metadata endpoint"
  type        = bool
  default     = false
}

######################
## SESSION LOGGING ##
####################

variable "session_logging_enabled" {
  default     = true
  type        = bool
  description = "To enable CloudWatch and S3 session logging or not. Note this does not apply to SSH sessions as AWS cannot log those sessions."
}

variable "session_logging_encryption_enabled" {
  default     = true
  type        = bool
  description = "To enable CloudWatch and S3 session logging encryption or not."
}

variable "cloudwatch_retention_in_days" {
  default     = 365
  type        = number
  description = "The number of days to retain session logs in CloudWatch. This is only relevant if the session_logging_enabled variable is `true`."
}

variable "session_logging_kms_key_arn" {
  default     = ""
  type        = string
  description = "BYO KMS Key instead of using the created KMS Key. The session_logging_encryption_enabled variable must still be `true` for this to be applied."
}

variable "session_logging_kms_key_alias" {
  default     = "alias/session_logging"
  type        = string
  description = "Alias name for `session_logging` KMS Key. This is only applied if 2 conditions are met: (1) `session_logging_kms_key_arn` is unset, (2) `session_logging_encryption_enabled` = true."
}


variable "session_logging_bucket_name" {
  default     = ""
  type        = string
  description = "The name of the S3 Bucket to ship session logs to. This will remove creation of an independent session logging bucket. This is only relevant if the session_logging_enabled variable is `true`."
}

variable "region" {
  default     = ""
  type        = string
  description = "The region to deploy the S3 bucket for session logs. If not supplied, the module will use the current region."
}

variable "create_run_shell_document" {
  default     = true
  type        = bool
  description = "Whether or not to create the SSM-SessionManagerRunShell SSM Document."
}

variable "session_logging_ssm_document_name" {
  default = "SSM-SessionManagerRunShell"
  type    = string

  description = "Name for `session_logging` SSM document. This is only applied if 2 conditions are met: (1) `session_logging_enabled` = true, (2) `create_run_shell_document` = true."
}
variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection for scale in actions on the ASG."
  type        = bool
  default     = false
}

variable "scale_in_protected_instances" {
  description = "Behavior when encountering instances protected from scale in are found. Available behaviors are Refresh, Ignore, and Wait. Default is Ignore."
  type        = string
  default     = "Ignore"

  validation {
    condition     = contains(["Refresh", "Ignore", "Wait"], var.scale_in_protected_instances)
    error_message = "scale_in_protected_instances must be one of Refresh, Ignore, or Wait"
  }
}
