variable "stage" {
  type        = string
  description = "The environment that this infrastrcuture is being deployed to e.g. dev, stage, or prod"
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "name" {
  default     = "ssm-agent"
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

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

variable "instance_type" {
  default     = "t3.nano"
  type        = string
  description = "The instance type to use for the SSM Agent EC2 Instnace."
}

variable "ami" {
  default     = ""
  type        = string
  description = "The AMI to use for the SSM Agent EC2 Instance. If not provided, the latest Amazon Linux 2 AMI will be used. Note: This will update periodically as AWS releases updates to their AL2 AMI."
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
