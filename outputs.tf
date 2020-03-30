output "security_group_id" {
  value = aws_security_group.default.id
}

output "ssm_agent_instance_id" {
  value = aws_instance.default.id
}

output "ssm_agent_role_id" {
  value = aws_iam_role.default.id
}
