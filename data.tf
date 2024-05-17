data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Most recent Amazon Linux 3 AMI
data "aws_ami" "amazon_linux_3" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}