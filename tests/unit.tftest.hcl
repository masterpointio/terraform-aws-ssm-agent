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

run "verify_session_logging_bucket_logic" {
  command = plan

  variables {
    session_logging_enabled     = true
    session_logging_bucket_name = "" # Empty name should trigger bucket creation
  }

  assert {
    condition     = local.logs_bucket_enabled == true
    error_message = "Logs bucket should be enabled when session logging is enabled and no bucket name is provided"
  }
}
