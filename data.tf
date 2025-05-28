data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Most recent Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = [var.architecture]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# A trunk-ignore rule is added here because the "owners" argument for this data resource is optional
# (as per the Terraform provider docs) and is intentionally omitted, since the consumer of this
# module can specify an arbitrary AMI ID as input. Therefore, the security of the AMI is a concern
# for the consumer. According to the AWS docs, if this value is not specified, the results include
# all images for which the caller has launch permissions.
#
# AWS docs: https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeImages.html.
#
# This rule was introduced in the following PR:
# https://github.com/masterpointio/terraform-aws-ssm-agent/pull/43.
#
# trunk-ignore(trivy/AVD-AWS-0344)
data "aws_ami" "instance" {
  count = length(var.ami) > 0 ? 1 : 0

  most_recent = true

  filter {
    name   = "image-id"
    values = [var.ami]
  }
}
