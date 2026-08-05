# Moved blocks for resources that will have count added
# These handle state migration when adding count = module.this.enabled ? 1 : 0

moved {
  from = aws_iam_role.default
  to   = aws_iam_role.default[0]
}

moved {
  from = aws_iam_role_policy_attachment.default
  to   = aws_iam_role_policy_attachment.default[0]
}

moved {
  from = aws_iam_instance_profile.default
  to   = aws_iam_instance_profile.default[0]
}

moved {
  from = aws_security_group.default
  to   = aws_security_group.default[0]
}

moved {
  from = aws_security_group_rule.allow_all_egress
  to   = aws_security_group_rule.allow_all_egress[0]
}

moved {
  from = aws_launch_template.default
  to   = aws_launch_template.default[0]
}

moved {
  from = aws_autoscaling_group.default
  to   = aws_autoscaling_group.default[0]
}

moved {
  from = terraform_data.vpc_subnet_validation
  to   = terraform_data.vpc_subnet_validation[0]
}
