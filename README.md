[![Masterpoint Logo](https://i.imgur.com/RDLnuQO.png)](https://masterpoint.io)

[![Release](https://img.shields.io/github/release/masterpointio/ecsrun.svg)](https://github.com/masterpointio/ecsrun/releases/latest)

# terraform-aws-ssm-agent

A Terraform Module to create a simple, autoscaled SSM Agent EC2 instance along with its corresponding IAM instance profile. This is intended to be used with SSM Session Manager and other SSM functionality to replace the need for a Bastion host and further secure your cloud environment. This includes an SSM document to enable session logging to S3 and CloudWatch for auditing purposes.

Big shout out to the following projects which this project uses/depends on/mentions:
1. [gjbae1212/gossm](https://github.com/gjbae1212/gossm)
1. [cloudposse/terraform-null-label](https://github.com/cloudposse/terraform-null-label)
1. [cloudposse/terraform-aws-vpc](https://github.com/cloudposse/terraform-aws-vpc)
1. [cloudposse/terraform-aws-dynamic-subnets](https://github.com/cloudposse/terraform-aws-dynamic-subnets)
1. [cloudposse/terraform-aws-kms-key](https://github.com/cloudposse/terraform-aws-kms-key)
1. [cloudposse/terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)
1. Cloud Posse's Terratest Setup.

![SSM Agent Session Manager Example](https://i.imgur.com/lWcRiQf.png)

## Usage

### Module Usage:

```hcl
module "ssm_agent" {
  source     = "git::https://github.com/masterpointio/terraform-aws-ssm-agent.git?ref=tags/0.1.0"
  stage      = var.stage
  namespace  = var.namespace
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.private_subnet_ids
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.10.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.19.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = var.nat_gateway_enabled
  nat_instance_enabled = ! var.nat_gateway_enabled
}
```

### Connecting to your new SSM Agent:

```bash
INSTANCE_ID=$(aws autoscaling describe-auto-scaling-instances | jq --raw-output ".AutoScalingInstances | .[0] | .InstanceId")
aws ssm start-session --target $INSTANCE_ID
```

OR

Use [the awesome `gossm` project](https://github.com/gjbae1212/gossm).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | >= 2.0 |
| local | >= 1.2 |
| null | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami | The AMI to use for the SSM Agent EC2 Instance. If not provided, the latest Amazon Linux 2 AMI will be used. Note: This will update periodically as AWS releases updates to their AL2 AMI. Pin to a specific AMI if you would like to avoid these updates. | `string` | `""` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| cloudwatch\_retention\_in\_days | The number of days to retain session logs in CloudWatch. This is only relevant if the session\_logging\_enabled variable is `true`. | `number` | `365` | no |
| create\_run\_shell\_document | Whether or not to create the SSM-SessionManagerRunShell SSM Document. | `bool` | `true` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| environment | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | `string` | `""` | no |
| instance\_count | The number of SSM Agent instances you would like to deploy. | `number` | `1` | no |
| instance\_type | The instance type to use for the SSM Agent EC2 Instnace. | `string` | `"t3.nano"` | no |
| key\_pair\_name | The name of the key-pair to associate with the SSM Agent instances. This can be (and probably should) left empty unless you specifically plan to use `AWS-StartSSHSession`. | `string` | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `"ssm-agent"` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| permissions\_boundary | The ARN of the permissions boundary that will be applied to the SSM Agent role. | `string` | `""` | no |
| region | The region to deploy the S3 bucket for session logs. If not supplied, the module will use the current region. | `string` | `""` | no |
| security_groups | Additional security groups to attach to SSM agents | `list(string)` | `[]` | no|
| session\_logging\_bucket\_name | The name of the S3 Bucket to ship session logs to. This will remove creation of an independent session logging bucket. This is only relevant if the session\_logging\_enabled variable is `true`. | `string` | `""` | no |
| session\_logging\_enabled | To enable CloudWatch and S3 session logging or not. Note this does not apply to SSH sessions as AWS cannot log those sessions. | `bool` | `true` | no |
| session\_logging\_encryption\_enabled | To enable CloudWatch and S3 session logging encryption or not. | `bool` | `true` | no |
| session\_logging\_kms\_key\_arn | BYO KMS Key instead of using the created KMS Key. The session\_logging\_encryption\_enabled variable must still be `true` for this to be applied. | `string` | `""` | no |
| stage | The environment that this infrastrcuture is being deployed to e.g. dev, stage, or prod | `string` | `""` | no |
| subnet\_ids | The Subnet IDs which the SSM Agent will run in. These *should* be private subnets. | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| user\_data | The user\_data to use for the SSM Agent EC2 instance. You can use this to automate installation of psql or other required command line tools. | `string` | `"#!/bin/bash\n# NOTE: Since we're using a latest Amazon Linux AMI, we shouldn't need this,\n# but we'll update it to be sure.\ncd /tmp\nsudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpmnsudo systemctl enable amazon-ssm-agent\nsudo systemctl start amazon-ssm-agent\n"` | no |
| vpc\_id | The ID of the VPC which the EC2 Instance will run in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_id | The ID of the SSM Agent Autoscaling Group. |
| instance\_name | The name tag value of the Bastion instance. |
| launch\_template\_id | The ID of the SSM Agent Launch Template. |
| role\_id | The ID of the SSM Agent Role. |
| security\_group\_id | The ID of the SSM Agent Security Group. |
| session\_logging\_bucket\_arn | The ARN of the SSM Agent Session Logging S3 Bucket. |
| session\_logging\_bucket\_id | The ID of the SSM Agent Session Logging S3 Bucket. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

