[![Masterpoint Logo](https://i.imgur.com/RDLnuQO.png)](https://masterpoint.io)

# terraform-aws-ssm-agent

A Terraform Module to create a simple, autoscaled SSM Agent EC2 instance along with its corresponding IAM instance profile. This can easily be used with SSM Session Manager and other SSM functionality to replace the need for a Bastion host and further secure your cloud environment.

Big shout out to the folks [@cloudposse](https://github.com/cloudposse), who have awesome open source modules which this repo uses heavily!

![SSM Agent Session Manager Example](https://i.imgur.com/lWcRiQf.png)

## Usage

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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami | The AMI to use for the SSM Agent EC2 Instance. If not provided, the latest Amazon Linux 2 AMI will be used. Note: This will update periodically as AWS releases updates to their AL2 AMI. Pin to a specific AMI if you would like to avoid these updates. | `string` | `""` | no |
| instance\_count | The number of SSM Agent instances you would like to deploy. | `number` | `1` | no |
| instance\_type | The instance type to use for the SSM Agent EC2 Instnace. | `string` | `"t3.nano"` | no |
| key\_pair\_name | The name of the key-pair to associate with the SSM Agent instances. This can be (and probably should) left empty unless you specifically plan to use `AWS-StartSSHSession`. | `string` | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `"ssm-agent"` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| permissions\_boundary | The ARN of the permissions boundary that will be applied to the SSM Agent role. | `string` | `""` | no |
| stage | The environment that this infrastrcuture is being deployed to e.g. dev, stage, or prod | `string` | n/a | yes |
| subnet\_ids | The Subnet IDs which the SSM Agent will run in. These *should* be private subnets. | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| user\_data | The user\_data to use for the SSM Agent EC2 instance. You can use this to automate installation of psql or other required command line tools. | `string` | `"#!/bin/bash\n# NOTE: Since we're using a latest Amazon Linux AMI, we shouldn't need this,\n# but we'll update it to be sure.\ncd /tmp\nsudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpmnsudo systemctl enable amazon-ssm-agent\nsudo systemctl start amazon-ssm-agent\n"` | no |
| vpc\_id | The ID of the VPC which the EC2 Instance will run in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_id | n/a |
| launch\_template\_id | n/a |
| role\_id | n/a |
| security\_group\_id | n/a |

