output "instance_name" {
  value       = module.label.id
  description = "The name tag value of the Bastion instance."
}

output "security_group_id" {
  value       = aws_security_group.default.id
  description = "The ID of the SSM Agent Security Group."
}

output "launch_template_id" {
  value       = aws_launch_template.default.id
  description = "The ID of the SSM Agent Launch Template."
}

output "autoscaling_group_id" {
  value       = aws_autoscaling_group.default.id
  description = "The ID of the SSM Agent Autoscaling Group."
}

output "role_id" {
  value       = aws_iam_role.default.id
  description = "The ID of the SSM Agent Role."
}

output "session_logging_bucket_id" {
  value       = var.session_logging_enabled && var.session_logging_bucket_name == "" ? join("", data.aws_s3_bucket.logs_bucket.*.id) : ""
  description = "The ID of the SSM Agent Session Logging S3 Bucket."
}

output "session_logging_bucket_arn" {
  value       = var.session_logging_enabled && var.session_logging_bucket_name == "" ? join("", data.aws_s3_bucket.logs_bucket.*.arn) : ""
  description = "The ARN of the SSM Agent Session Logging S3 Bucket."
}
