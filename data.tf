data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# VPC lookup by name (when vpc_name is provided)
data "aws_vpc" "selected" {
  count = var.vpc_name != null ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Individual subnet lookup by name (when subnet_names are provided)
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_names)

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

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
# trivy:ignore:AVD-AWS-0344
data "aws_ami" "instance" {
  count = length(var.ami) > 0 ? 1 : 0

  most_recent = true

  filter {
    name   = "image-id"
    values = [var.ami]
  }
}

# IAM policy document for EC2 instances to assume the SSM Agent role
data "aws_iam_policy_document" "default" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html#create-iam-instance-profile-ssn-logging
data "aws_iam_policy_document" "session_logging" {
  count = var.session_logging_enabled ? 1 : 0

  statement {
    sid    = "SSMAgentSessionAllowS3Logging"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${local.session_logging_bucket_arn}/*"]
  }

  statement {
    sid    = "SSMAgentSessionAllowCloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${local.session_logging_log_group_arn}:*"]
  }

  statement {
    sid    = "SSMAgentSessionAllowCloudWatchDescribe"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [local.session_logging_log_group_arn]
  }

  statement {
    sid    = "SSMAgentSessionAllowGetEncryptionConfig"
    effect = "Allow"
    actions = [
      "s3:GetEncryptionConfiguration"
    ]
    resources = [local.session_logging_bucket_arn]
  }

  statement {
    sid    = "SSMAgentSessionAllowKMSDataKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey"
    ]
    resources = [local.session_logging_kms_key_arn]
  }
}
