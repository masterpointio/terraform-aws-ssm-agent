[![Banner][banner-image]](https://masterpoint.io/)

# terraform-aws-ssm-agent

[![Release][release-badge]][latest-release]

💡 Learn more about Masterpoint [below](#who-we-are-𐦂𖨆𐀪𖠋).

## Purpose and Functionality

A Terraform Module to create a simple, autoscaled SSM Agent EC2 instance along with its corresponding IAM instance profile.

This is intended to be used with SSM Session Manager and other SSM functionality to replace the need for a Bastion host and further secure your cloud environment. This includes an SSM document to enable session logging to S3 and CloudWatch for auditing purposes.

Big shout out to the following projects which this project uses/depends on/mentions:

1. [gjbae1212/gossm](https://github.com/gjbae1212/gossm)
1. [cloudposse/terraform-null-label](https://github.com/cloudposse/terraform-null-label)
1. [cloudposse/terraform-aws-vpc](https://github.com/cloudposse/terraform-aws-vpc)
1. [cloudposse/terraform-aws-dynamic-subnets](https://github.com/cloudposse/terraform-aws-dynamic-subnets)
1. [cloudposse/terraform-aws-kms-key](https://github.com/cloudposse/terraform-aws-kms-key)
1. [cloudposse/terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)

![SSM Agent Session Manager Example](https://i.imgur.com/lWcRiQf.png)

## Usage

### Module Usage

```hcl
module "ssm_agent" {
  source  = "masterpointio/ssm-agent/aws"
  version = "X.X.X"

  namespace = var.namespace
  stage     = var.stage

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.private_subnet_ids
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "X.X.X"

  namespace = var.namespace
  stage     = var.stage
  name      = var.name

  ipv4_primary_cidr_block          = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "X.X.X"

  namespace = var.namespace
  stage     = var.stage

  availability_zones = var.availability_zones
  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  ipv4_cidr_block    = [module.vpc.vpc_cidr_block]
  ipv6_enabled       = var.ipv6_enabled
}
```

### Connecting to your new SSM Agent

Prereqs:

- Your IAM users/role needs: `ssm:StartSession`, `ec2:DescribeInstances`

```bash
INSTANCE_ID=$(aws autoscaling describe-auto-scaling-instances | jq --raw-output ".AutoScalingInstances | .[0] | .InstanceId")
aws ssm start-session --target $INSTANCE_ID
```

OR

Use [the awesome `gossm` project](https://github.com/gjbae1212/gossm).

### Set up port forwarding through your SSM Agent

For example, set up port forwarding on `localhost` to connect to an RDS Postgres instance on private subnets that is not publicly accessible.

Prereqs:

- Your IAM user/role needs the following permissions: `ssm:StartSession`, `ec2:DescribeInstances`, `rds:DescribeDBInstances`
- Ensure the network architecture and Security Group permissions allow inbound traffic from the SSM Agent EC2 host.

```bash
REGION=us-east-1
# Partial match for RDS instance name (e.g., "polygon" matches "acme-prod-polygon-data")
DB_INSTANCE_SUBSTRING="polygon"
LOCAL_PORT=15432

# 1) Find the running SSM gateway instance ID by tag
INSTANCE_ID="$(
  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*ssm*" "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --region ${AWS_REGION} \
  --output text)"

# 2) Find the RDS instance endpoint
RDS_ENDPOINT="$(
	aws rds describe-db-instances \
  --region ${AWS_REGION} \
  --query "DBInstances[?contains(DBInstanceIdentifier, '${DB_INSTANCE_SUBSTRING}')].Endpoint.Address | [0]" \
  --output text)"

# 3) Dynamically get the RDS port
RDS_PORT="$(
	aws rds describe-db-instances \
  --region ${AWS_REGION} \
  --query "DBInstances[?contains(DBInstanceIdentifier, '${DB_INSTANCE_SUBSTRING}')].Endpoint.Port | [0]" \
  --output text)"

echo "EC2 Instance ID: $INSTANCE_ID"
echo "RDS Endpoint: $RDS_ENDPOINT"
echo "Setting up port forwarding (ec2) ${RDS_PORT} -> (localhost) ${LOCAL_PORT}"

# 4) Start the port forwarding session
aws ssm start-session \
  --target $INSTANCE_ID \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$RDS_ENDPOINT\"],\"portNumber\":[\"$RDS_PORT\"],\"localPortNumber\":[\"$LOCAL_PORT\"]}"
```

<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | cloudposse/kms-key/aws | 0.12.1 |
| <a name="module_logs_bucket"></a> [logs\_bucket](#module\_logs\_bucket) | cloudposse/s3-bucket/aws | 4.10.0 |
| <a name="module_logs_label"></a> [logs\_label](#module\_logs\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_role_label"></a> [role\_label](#module\_role\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.session_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.session_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_all_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_document.session_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [null_resource.validate_instance_type](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [terraform_data.vpc_subnet_validation](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_ami.amazon_linux_2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.session_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | Security groups that will be attached to the app instances | `list(string)` | `[]` | no |
| <a name="input_additional_security_group_rules"></a> [additional\_security\_group\_rules](#input\_additional\_security\_group\_rules) | Additional security group rules that will be attached to the primary security group | <pre>map(object({<br/>    type      = string<br/>    from_port = number<br/>    to_port   = number<br/>    protocol  = string<br/><br/>    description      = optional(string)<br/>    cidr_blocks      = optional(list(string))<br/>    ipv6_cidr_blocks = optional(list(string))<br/>    prefix_list_ids  = optional(list(string))<br/>    self             = optional(bool)<br/>  }))</pre> | `{}` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allow_encrypted_uploads_only"></a> [allow\_encrypted\_uploads\_only](#input\_allow\_encrypted\_uploads\_only) | Whether or not to allow encrypted uploads only. If set to `true` this will create a bucket policy that `Deny` if encryption header is missing in the requests. | `bool` | `false` | no |
| <a name="input_allow_ssl_requests_only"></a> [allow\_ssl\_requests\_only](#input\_allow\_ssl\_requests\_only) | Whether or not to allow SSL requests only. If set to `true` this will create a bucket policy that `Deny` if SSL is not used in the requests using the `aws:SecureTransport` condition. | `bool` | `false` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | The AMI to use for the SSM Agent EC2 Instance. If not provided, the latest Amazon Linux 2023 AMI will be used. Note: This will update periodically as AWS releases updates to their AL2023 AMI. Pin to a specific AMI if you would like to avoid these updates. | `string` | `""` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | The architecture of the AMI (e.g., x86\_64, arm64) | `string` | `"arm64"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Associate public IP address | `bool` | `null` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_retention_in_days"></a> [cloudwatch\_retention\_in\_days](#input\_cloudwatch\_retention\_in\_days) | The number of days to retain session logs in CloudWatch. This is only relevant if the session\_logging\_enabled variable is `true`. | `number` | `365` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_create_run_shell_document"></a> [create\_run\_shell\_document](#input\_create\_run\_shell\_document) | Whether or not to create the SSM-SessionManagerRunShell SSM Document. | `bool` | `true` | no |
| <a name="input_custom_policy_document"></a> [custom\_policy\_document](#input\_custom\_policy\_document) | JSON policy document for custom permissions to attach to the SSM Agent role. If not provided, no custom policy will be attached. | `string` | `""` | no |
| <a name="input_custom_policy_name"></a> [custom\_policy\_name](#input\_custom\_policy\_name) | Name for the custom policy. Only used if custom\_policy\_document is provided. | `string` | `"custom-policy"` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired number of instances in the Auto Scaling Group | `number` | `1` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the SSM Agent EC2 instance. | `string` | `"t4g.nano"` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | The name of the key-pair to associate with the SSM Agent instances. This can be (and probably should) left empty unless you specifically plan to use `AWS-StartSSHSession`. | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of instances in the Auto Scaling Group | `number` | `2` | no |
| <a name="input_metadata_http_endpoint_enabled"></a> [metadata\_http\_endpoint\_enabled](#input\_metadata\_http\_endpoint\_enabled) | Whether or not to enable the metadata http endpoint | `bool` | `true` | no |
| <a name="input_metadata_http_protocol_ipv6_enabled"></a> [metadata\_http\_protocol\_ipv6\_enabled](#input\_metadata\_http\_protocol\_ipv6\_enabled) | Enable IPv6 metadata endpoint | `bool` | `false` | no |
| <a name="input_metadata_imdsv2_enabled"></a> [metadata\_imdsv2\_enabled](#input\_metadata\_imdsv2\_enabled) | Whether or not the metadata service requires session tokens,<br/>also referred to as Instance Metadata Service Version 2 (IMDSv2). | `bool` | `true` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of instances in the Auto Scaling Group | `number` | `1` | no |
| <a name="input_monitoring_enabled"></a> [monitoring\_enabled](#input\_monitoring\_enabled) | Enable detailed monitoring of instance | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | The ARN of the permissions boundary that will be applied to the SSM Agent role. | `string` | `""` | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | Allows setting instance protection for scale in actions on the ASG. | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy the S3 bucket for session logs. If not supplied, the module will use the current region. | `string` | `""` | no |
| <a name="input_scale_in_protected_instances"></a> [scale\_in\_protected\_instances](#input\_scale\_in\_protected\_instances) | Behavior when encountering instances protected from scale in are found. Available behaviors are Refresh, Ignore, and Wait. Default is Ignore. | `string` | `"Ignore"` | no |
| <a name="input_session_logging_bucket_name"></a> [session\_logging\_bucket\_name](#input\_session\_logging\_bucket\_name) | The name of the S3 Bucket to ship session logs to. This will remove creation of an independent session logging bucket. This is only relevant if the session\_logging\_enabled variable is `true`. | `string` | `""` | no |
| <a name="input_session_logging_enabled"></a> [session\_logging\_enabled](#input\_session\_logging\_enabled) | To enable CloudWatch and S3 session logging or not. Note this does not apply to SSH sessions as AWS cannot log those sessions. | `bool` | `true` | no |
| <a name="input_session_logging_encryption_enabled"></a> [session\_logging\_encryption\_enabled](#input\_session\_logging\_encryption\_enabled) | To enable CloudWatch and S3 session logging encryption or not. | `bool` | `true` | no |
| <a name="input_session_logging_kms_key_alias"></a> [session\_logging\_kms\_key\_alias](#input\_session\_logging\_kms\_key\_alias) | Alias name for `session_logging` KMS Key. This is only applied if 2 conditions are met: (1) `session_logging_kms_key_arn` is unset, (2) `session_logging_encryption_enabled` = true. | `string` | `"alias/session_logging"` | no |
| <a name="input_session_logging_kms_key_arn"></a> [session\_logging\_kms\_key\_arn](#input\_session\_logging\_kms\_key\_arn) | BYO KMS Key instead of using the created KMS Key. The session\_logging\_encryption\_enabled variable must still be `true` for this to be applied. | `string` | `""` | no |
| <a name="input_session_logging_ssm_document_name"></a> [session\_logging\_ssm\_document\_name](#input\_session\_logging\_ssm\_document\_name) | Name for `session_logging` SSM document. This is only applied if 2 conditions are met: (1) `session_logging_enabled` = true, (2) `create_run_shell_document` = true. | `string` | `"SSM-SessionManagerRunShell"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The Subnet IDs which the SSM Agent will run in. These *should* be private subnets. | `list(string)` | `[]` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | The Subnet names which the SSM Agent will run in. If provided, subnet\_ids will be ignored. These *should* be private subnets. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user\_data to use for the SSM Agent EC2 instance. You can use this to automate installation of psql or other required command line tools. | `string` | `"#!/bin/bash\n# NOTE: Since we're using a latest Amazon Linux AMI, we shouldn't need this,\n# but we'll update it to be sure.\ncd /tmp\nsudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpmnsudo systemctl enable amazon-ssm-agent\nsudo systemctl start amazon-ssm-agent\n"` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size of the volume in gigabytes. | `number` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC which the EC2 Instance will run in. | `string` | `null` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the VPC which the EC2 Instance will run in. If provided, vpc\_id will be ignored. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id) | The ID of the SSM Agent Autoscaling Group. |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | The name tag value of the Bastion instance. |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | The ID of the SSM Agent Launch Template. |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The ID of the SSM Agent Role. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the SSM Agent Security Group. |
| <a name="output_session_logging_bucket_arn"></a> [session\_logging\_bucket\_arn](#output\_session\_logging\_bucket\_arn) | The ARN of the SSM Agent Session Logging S3 Bucket. |
| <a name="output_session_logging_bucket_id"></a> [session\_logging\_bucket\_id](#output\_session\_logging\_bucket\_id) | The ID of the SSM Agent Session Logging S3 Bucket. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->

## Built By

Powered by the [Masterpoint team](https://masterpoint.io/who-we-are/) and driven forward by contributions from the community ❤️

[![Contributors][contributors-image]][contributors-url]

## Contribution Guidelines

Contributions are welcome and appreciated!

Found an issue or want to request a feature? [Open an issue][issues-url]

Want to fix a bug you found or add some functionality? Fork, clone, commit, push, and PR — we'll check it out.

## Who We Are 𐦂𖨆𐀪𖠋

Established in 2016, Masterpoint is a team of experienced software and platform engineers specializing in Infrastructure as Code (IaC). We provide expert guidance to organizations of all sizes, helping them leverage the latest IaC practices to accelerate their engineering teams.

### Our Mission

Our mission is to simplify cloud infrastructure so developers can innovate faster, safer, and with greater confidence. By open-sourcing tools and modules that we use internally, we aim to contribute back to the community, promoting consistency, quality, and security.

### Our Commitments

- 🌟 **Open Source**: We live and breathe open source, contributing to and maintaining hundreds of projects across multiple organizations.
- 🌎 **1% for the Planet**: Demonstrating our commitment to environmental sustainability, we are proud members of [1% for the Planet](https://www.onepercentfortheplanet.org), pledging to donate 1% of our annual sales to environmental nonprofits.
- 🇺🇦 **1% Towards Ukraine**: With team members and friends affected by the ongoing [Russo-Ukrainian war](https://en.wikipedia.org/wiki/Russo-Ukrainian_War), we donate 1% of our annual revenue to invasion relief efforts, supporting organizations providing aid to those in need. [Here's how you can help Ukraine with just a few clicks](https://masterpoint.io/updates/supporting-ukraine/).

## Connect With Us

We're active members of the community and are always publishing content, giving talks, and sharing our hard earned expertise. Here are a few ways you can see what we're up to:

[![LinkedIn][linkedin-badge]][linkedin-url] [![Newsletter][newsletter-badge]][newsletter-url] [![Blog][blog-badge]][blog-url] [![YouTube][youtube-badge]][youtube-url]

... and be sure to connect with our founder, [Matt Gowie](https://www.linkedin.com/in/gowiem/).

## License

[Apache License, Version 2.0][license-url].

[![Open Source Initiative][osi-image]][license-url]

Copyright © 2016-2025 [Masterpoint Consulting LLC](https://masterpoint.io/)

<!-- MARKDOWN LINKS & IMAGES -->

[banner-image]: https://masterpoint-public.s3.us-west-2.amazonaws.com/v2/standard-long-fullcolor.png
[license-url]: https://opensource.org/license/apache-2-0
[osi-image]: https://i0.wp.com/opensource.org/wp-content/uploads/2023/03/cropped-OSI-horizontal-large.png?fit=250%2C229&ssl=1
[linkedin-badge]: https://img.shields.io/badge/LinkedIn-Follow-0A66C2?style=for-the-badge&logoColor=white
[linkedin-url]: https://www.linkedin.com/company/masterpoint-consulting
[blog-badge]: https://img.shields.io/badge/Blog-IaC_Insights-55C1B4?style=for-the-badge&logoColor=white
[blog-url]: https://masterpoint.io/updates/
[newsletter-badge]: https://img.shields.io/badge/Newsletter-Subscribe-ECE295?style=for-the-badge&logoColor=222222
[newsletter-url]: https://newsletter.masterpoint.io/
[youtube-badge]: https://img.shields.io/badge/YouTube-Subscribe-D191BF?style=for-the-badge&logo=youtube&logoColor=white
[youtube-url]: https://www.youtube.com/channel/UCeeDaO2NREVlPy9Plqx-9JQ

<!-- TODO: Replace `terraform-aws-ssm-agent` with your actual repository name. -->

[release-badge]: https://img.shields.io/github/v/release/masterpointio/terraform-aws-ssm-agent?color=0E383A&label=Release&style=for-the-badge&logo=github&logoColor=white
[latest-release]: https://github.com/masterpointio/terraform-aws-ssm-agent/releases/latest
[contributors-image]: https://contrib.rocks/image?repo=masterpointio/terraform-aws-ssm-agent
[contributors-url]: https://github.com/masterpointio/terraform-aws-ssm-agent/graphs/contributors
[issues-url]: https://github.com/masterpointio/terraform-aws-ssm-agent/issues
