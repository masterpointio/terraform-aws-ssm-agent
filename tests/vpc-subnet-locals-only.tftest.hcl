# Minimal tests for VPC and subnet locals logic only

mock_provider "aws" {
  mock_data "aws_vpc" {
    defaults = {
      id = "vpc-from-name"
    }
  }

  mock_data "aws_subnet" {
    defaults = {
      id = "subnet-from-name"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name = "us-east-1"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_ami" {
    defaults = {
      id = "ami-mock"
      root_device_name = "/dev/xvda"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_s3_bucket" {
    defaults = {
      id = "mock-bucket"
      arn = "arn:aws:s3:::mock-bucket"
    }
  }

  # Mock AWS resources that get created in the module
  mock_resource "aws_launch_template" {
    defaults = {
      id = "lt-mock123456"
      latest_version = "1"
    }
  }
}

# Test precedence - names over IDs
run "test_precedence_local" {
  command = plan

  variables {
    vpc_id       = "vpc-should-be-ignored"
    vpc_name     = "my-vpc"
    subnet_ids   = ["subnet-should-be-ignored"]
    subnet_names = ["my-subnet"]
    session_logging_enabled = false

    # Add required context variables for proper naming
    namespace = "test"
    stage     = "unit"
    name      = "ssm-agent"
  }

  # Expect warnings from check blocks since we're providing both IDs and names
  expect_failures = [
    check.vpc_subnet_warnings
  ]

  assert {
    condition     = local.vpc_id == "vpc-from-name"
    error_message = "VPC name should take precedence"
  }

  assert {
    condition     = contains(local.subnet_ids, "subnet-from-name")
    error_message = "Subnet names should take precedence"
  }
}
