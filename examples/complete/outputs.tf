output "security_group_id" {
  value       = module.ssm_agent.security_group_id
  description = "The ID of the SSM Agent Security Group."
}

output "launch_template_id" {
  value       = module.ssm_agent.launch_template_id
  description = "The ID of the SSM Agent Launch Template."
}

output "autoscaling_group_id" {
  value       = module.ssm_agent.autoscaling_group_id
  description = "The ID of the SSM Agent Autoscaling Group."
}

output "role_id" {
  value       = module.ssm_agent.role_id
  description = "The ID of the SSM Agent Role."
}

output "session_logging_bucket_id" {
  value       = module.ssm_agent.session_logging_bucket_id
  description = "The ID of the SSM Agent Session Logging S3 Bucket."
}

output "session_logging_bucket_arn" {
  value       = module.ssm_agent.session_logging_bucket_arn
  description = "The ARN of the SSM Agent Session Logging S3 Bucket."
}
