output "security_group_id" {
  value = aws_security_group.default.id
}

output "launch_template_id" {
  value = aws_launch_template.default.id
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.default.id
}

output "role_id" {
  value = aws_iam_role.default.id
}
