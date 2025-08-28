output "ssm_agent_with_ids_instance_profile_arn" {
  description = "ARN of the IAM instance profile for SSM agent (using IDs)"
  value       = module.ssm_agent_with_ids.iam_instance_profile_arn
}

output "ssm_agent_with_names_instance_profile_arn" {
  description = "ARN of the IAM instance profile for SSM agent (using names)"
  value       = module.ssm_agent_with_names.iam_instance_profile_arn
}

output "ssm_agent_mixed_instance_profile_arn" {
  description = "ARN of the IAM instance profile for SSM agent (mixed approach)"
  value       = module.ssm_agent_mixed.iam_instance_profile_arn
}
