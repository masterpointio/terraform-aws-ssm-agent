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

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC which the EC2 Instance will run in."
}

variable "subnet_id" {
  type        = string
  description = "The Subnet ID which the SSM Agent will run in. This *should* be a private subnet."
}

variable "permissions_boundary" {
  default     = ""
  type        = string
  description = "The ARN of the permissions boundary that will be applied to the SSM Agent role."
}

variable "instance_type" {
  default     = "t2.micro"
  type        = string
  description = "The instance type to use for the SSM Agent EC2 Instnace."
}

variable "ami" {
  default     = ""
  type        = string
  description = "The AMI to use for the SSM Agent EC2 Instance. If not provided, the latest Amazon Linux 2 AMI will be used. Note: This will update periodically as AWS releases updates to their AL2 AMI."
}

variable "ssm_policy_arn" {
  default     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  type        = string
  description = "The ARN of a policy to provide for the role. By default, this uses Amazon's managed SSM Instance policy, which allows the instance to use the core SSM functionality."
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
