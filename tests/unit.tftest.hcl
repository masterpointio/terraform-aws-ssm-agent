variables {
  vpc_id              = "vpc-12345678"
  subnet_ids          = ["subnet-12345678", "subnet-87654321"]
  stage               = "test"
  namespace           = "mp"
  name                = "ssm-agent"
  region              = "us-east-1"
  availability_zones  = ["us-east-1a"]
  nat_gateway_enabled = true
  ipv6_enabled        = true
}

run "verify_session_logging" {
  command = plan

  variables {
    session_logging_enabled            = true
    session_logging_bucket_name        = ""
    session_logging_encryption_enabled = true
    cloudwatch_retention_in_days       = 365
  }

  assert {
    condition     = aws_cloudwatch_log_group.session_logging[0].retention_in_days == 365
    error_message = "CloudWatch log retention days not set correctly when variables passed in."
  }

  assert {
    condition     = length(aws_iam_role_policy.session_logging) > 0
    error_message = "Session logging IAM policy not created when variables passed in."
  }
}

run "verify_launch_template" {
  command = plan

  variables {
    instance_type               = "c6g.nano"
    monitoring_enabled          = true
    associate_public_ip_address = false
    metadata_imdsv2_enabled     = true
    namespace                   = "mp"
    stage                       = "test"
    name                        = "ssm-agent"
  }

  assert {
    condition     = aws_launch_template.default.instance_type == "c6g.nano"
    error_message = "Launch template instance type does not match"
  }

  assert {
    condition     = aws_launch_template.default.monitoring[0].enabled == true
    error_message = "Instance monitoring not enabled"
  }

  assert {
    condition     = aws_launch_template.default.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 not enforced in launch template"
  }

  assert {
    condition     = aws_launch_template.default.iam_instance_profile[0].name == "mp-test-ssm-agent-role"
    error_message = "IAM instance profile name does not match expected value"
  }

  assert {
    condition     = aws_launch_template.default.iam_instance_profile[0].name == aws_iam_instance_profile.default.name
    error_message = "Launch template IAM instance profile name does not match the created instance profile"
  }
}

run "verify_autoscaling_group" {
  command = plan

  variables {
    max_size         = 2
    min_size         = 1
    desired_capacity = 1
    subnet_ids       = ["subnet-12345678"]
  }

  assert {
    condition     = aws_autoscaling_group.default.max_size == 2
    error_message = "ASG max size not set correctly"
  }

  assert {
    condition     = aws_autoscaling_group.default.min_size == 1
    error_message = "ASG min size not set correctly"
  }

  assert {
    condition     = aws_autoscaling_group.default.desired_capacity == 1
    error_message = "ASG desired capacity not set correctly"
  }
}


run "verify_s3_bucket_configuration" {
  command = plan

  variables {
    session_logging_enabled = true
  }

  assert {
    condition     = module.logs_bucket.enabled == true
    error_message = "S3 bucket session logging bucket isn't enabled when set to enabled."
  }
}
