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
  default     = "t3.nano"
  type        = string
  description = "The instance type to use for the SSM Agent EC2 Instnace."
}

variable "ami" {
  default     = ""
  type        = string
  description = "The AMI to use for the SSM Agent EC2 Instance. If not provided, the latest Amazon Linux 2 AMI will be used. Note: This will update periodically as AWS releases updates to their AL2 AMI. Pin to a specific AMI if you would like to avoid these updates."
}

variable "instance_count" {
  default     = 1
  type        = number
  description = "The number of SSM Agent instances you would like to deploy."
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
  default     = "SSM-SessionManagerRunShell"
  type        = string
  description = "Name for `session_logging` SSM document. This is only applied if 2 conditions are met: (1) `session_logging_enabled` = true, (2) `create_run_shell_document` = true."
}
