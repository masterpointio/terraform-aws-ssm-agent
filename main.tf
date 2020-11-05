/**
 * [![Masterpoint Logo](https://i.imgur.com/RDLnuQO.png)](https://masterpoint.io)
 *
 * [![Release](https://img.shields.io/github/release/masterpointio/ecsrun.svg)](https://github.com/masterpointio/ecsrun/releases/latest)
 *
 * # terraform-aws-ssm-agent
 *
 * A Terraform Module to create a simple, autoscaled SSM Agent EC2 instance along with its corresponding IAM instance profile. This is intended to be used with SSM Session Manager and other SSM functionality to replace the need for a Bastion host and further secure your cloud environment. This includes an SSM document to enable session logging to S3 and CloudWatch for auditing purposes.
 *
 * Big shout out to the following projects which this project uses/depends on/mentions:
 * 1. [gjbae1212/gossm](https://github.com/gjbae1212/gossm)
 * 1. [cloudposse/terraform-null-label](https://github.com/cloudposse/terraform-null-label)
 * 1. [cloudposse/terraform-aws-vpc](https://github.com/cloudposse/terraform-aws-vpc)
 * 1. [cloudposse/terraform-aws-dynamic-subnets](https://github.com/cloudposse/terraform-aws-dynamic-subnets)
 * 1. [cloudposse/terraform-aws-kms-key](https://github.com/cloudposse/terraform-aws-kms-key)
 * 1. [cloudposse/terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)
 * 1. Cloud Posse's Terratest Setup.
 *
 * ![SSM Agent Session Manager Example](https://i.imgur.com/lWcRiQf.png)
 *
 * ## Usage
 *
 * ### Module Usage:
 *
 * ```hcl
 * module "ssm_agent" {
 *   source     = "git::https://github.com/masterpointio/terraform-aws-ssm-agent.git?ref=tags/0.1.0"
 *   stage      = var.stage
 *   namespace  = var.namespace
 *   vpc_id     = module.vpc.vpc_id
 *   subnet_ids = module.subnets.private_subnet_ids
 * }
 *
 * module "vpc" {
 *   source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.10.0"
 *   namespace  = var.namespace
 *   stage      = var.stage
 *   name       = var.name
 *   cidr_block = "10.0.0.0/16"
 * }
 *
 * module "subnets" {
 *   source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.19.0"
 *   availability_zones   = var.availability_zones
 *   namespace            = var.namespace
 *   stage                = var.stage
 *   vpc_id               = module.vpc.vpc_id
 *   igw_id               = module.vpc.igw_id
 *   cidr_block           = module.vpc.vpc_cidr_block
 *   nat_gateway_enabled  = var.nat_gateway_enabled
 *   nat_instance_enabled = ! var.nat_gateway_enabled
 * }
 * ```
 *
 * ### Connecting to your new SSM Agent:
 *
 * ```bash
 * INSTANCE_ID=$(aws autoscaling describe-auto-scaling-instances | jq --raw-output ".AutoScalingInstances | .[0] | .InstanceId")
 * aws ssm start-session --target $INSTANCE_ID
 * ```
 *
 * OR
 *
 * Use [the awesome `gossm` project](https://github.com/gjbae1212/gossm).
 *
 */

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.19.2"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags

  additional_tag_map = {
    propagate_at_launch = "true"
  }
}

module "role_label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.19.2"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = compact(concat(["role"], var.attributes))
  tags        = var.tags
}

module "logs_label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.19.2"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = compact(concat(["logs"], var.attributes))
  tags        = var.tags
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region     = coalesce(var.region, data.aws_region.current.name)
  account_id = data.aws_caller_identity.current.account_id
}

#####################
## SSM AGENT ROLE ##
###################

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

data "aws_s3_bucket" "logs_bucket" {
  bucket = coalesce(var.session_logging_bucket_name, module.logs_bucket.bucket_id)
}

# https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html#create-iam-instance-profile-ssn-logging
data "aws_iam_policy_document" "session_logging" {

  statement {
    sid    = "SSMAgentSessionAllowS3Logging"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${data.aws_s3_bucket.logs_bucket.arn}/*"]
  }

  statement {
    sid    = "SSMAgentSessionAllowCloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SSMAgentSessionAllowGetEncryptionConfig"
    effect = "Allow"
    actions = [
      "s3:GetEncryptionConfiguration"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SSMAgentSessionAllowKMSDataKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "default" {
  name                 = module.role_label.id
  assume_role_policy   = data.aws_iam_policy_document.default.json
  permissions_boundary = var.permissions_boundary
  tags                 = module.role_label.tags
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "session_logging" {
  count = var.session_logging_enabled ? 1 : 0

  name   = "${module.role_label.id}-session-logging"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.session_logging.json
}

resource "aws_iam_instance_profile" "default" {
  name = module.role_label.id
  role = aws_iam_role.default.name
}

#####################
## SECURITY GROUP ##
###################

resource "aws_security_group" "default" {
  vpc_id      = var.vpc_id
  name        = module.label.id
  description = "Allow ALL egress from SSM Agent."
  tags        = module.label.tags
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

#######################
## SECURITY LOGGING ##
#####################

module "kms_key" {
  source  = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=tags/0.7.0"
  enabled = var.session_logging_enabled && var.session_logging_encryption_enabled && var.session_logging_kms_key_arn == ""

  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = module.logs_label.attributes
  tags        = var.tags

  description             = "KMS key for encrypting Session Logs in S3 and CloudWatch."
  deletion_window_in_days = 10
  enable_key_rotation     = true
  alias                   = "alias/session_logging_key"

  policy = <<DOC
{
  "Version" : "2012-10-17",
  "Id" : "${module.logs_label.id}-policy",
  "Statement" : [
    {
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "*"
      },
      "Action" : "kms:*",
      "Resource" : "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${local.region}.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*",
      "Condition": {
        "ArnLike": {
          "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${local.region}:${local.account_id}:log-group:${module.logs_label.id}"
        }
      }
    }
  ]
}
DOC
}

module "logs_bucket" {
  source  = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=0.20.0"
  enabled = var.session_logging_enabled && var.session_logging_bucket_name == ""

  # General
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = module.logs_label.attributes
  tags        = var.tags
  region      = local.region

  # Encryption / Security
  acl                          = "private"
  sse_algorithm                = "aws:kms"
  kms_master_key_arn           = coalesce(var.session_logging_kms_key_arn, module.kms_key.key_arn)
  allow_encrypted_uploads_only = false
  force_destroy                = true

  # Feature enablement
  user_enabled              = false
  versioning_enabled        = true
  lifecycle_rule_enabled    = true
  enable_glacier_transition = true

  # Lifecycle Transitions
  noncurrent_version_transition_days = 30
  noncurrent_version_expiration_days = 365
  standard_transition_days           = 30
  glacier_transition_days            = 90
  expiration_days                    = 0
}

resource "aws_cloudwatch_log_group" "session_logging" {
  count = var.session_logging_enabled ? 1 : 0

  name              = module.logs_label.id
  retention_in_days = var.cloudwatch_retention_in_days
  kms_key_id        = var.session_logging_encryption_enabled ? coalesce(var.session_logging_kms_key_arn, module.kms_key.key_arn) : ""
  tags              = module.logs_label.tags
}

resource "aws_ssm_document" "session_logging" {
  count = var.session_logging_enabled && var.create_run_shell_document ? 1 : 0

  name          = "SSM-SessionManagerRunShell"
  document_type = "Session"
  tags          = module.logs_label.tags
  content       = <<DOC
{
  "schemaVersion": "1.0",
  "description": "Document to hold regional settings for Session Manager",
  "sessionType": "Standard_Stream",
  "inputs": {
    "s3BucketName": "${coalesce(var.session_logging_bucket_name, module.logs_label.id)}",
    "s3KeyPrefix": "logs/",
    "s3EncryptionEnabled": true,
    "cloudWatchLogGroupName": "${module.logs_label.id}",
    "cloudWatchEncryptionEnabled": true,
    "kmsKeyId": "${coalesce(var.session_logging_kms_key_arn, module.kms_key.key_arn)}",
    "runAsEnabled": false,
    "runAsDefaultUser": ""
  }
}
DOC
}



############################
## LAUNCH TEMPLATE + ASG ##
##########################

resource "aws_launch_template" "default" {
  name_prefix   = module.label.id
  image_id      = var.ami != "" ? var.ami : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  user_data     = base64encode(var.user_data)

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = concat(var.security_groups, [aws_security_group.default.id])
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.default.name
  }

  tag_specifications {
    resource_type = "instance"
    tags          = module.label.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = module.label.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  name_prefix = "${module.label.id}-asg"
  tags        = module.label.tags_as_list_of_maps

  launch_template {
    id      = aws_launch_template.default.id
    version = "$Latest"
  }

  max_size         = var.instance_count
  min_size         = var.instance_count
  desired_capacity = var.instance_count

  vpc_zone_identifier = var.subnet_ids

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  termination_policies = [
    "OldestLaunchConfiguration",
  ]

  lifecycle {
    create_before_destroy = true
  }
}
