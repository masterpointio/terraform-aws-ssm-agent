output "ssm_agent_security_group_id" {
  value = module.ssm_agent.security_group_id
}

output "ssm_agent_launch_template_id" {
  value = module.ssm_agent.launch_template_id
}

output "ssm_agent_autoscaling_group_id" {
  value = module.ssm_agent.autoscaling_group_id
}

output "ssm_agent_role_id" {
  value = module.ssm_agent.role_id
}
