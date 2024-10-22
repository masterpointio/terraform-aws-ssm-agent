### Integration Tests for the SSM Agent Module
### This test suite will create the SSM Agent module
### and validate the resources created by the module,
### then destroy it.

### `/test-harness/` module is used as a helper to validate resources that aren't in the Terraform state, for example the EC2 instances created from the ASG.

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "create_ssm_agent" {
  command = apply

  variables {
    namespace = "mp"
    stage     = "terraform-test${run.setup.random_number}"
  }

  module {
    source = "./examples/complete"
  }

  assert {
    condition     = module.ssm_agent.security_group_id != ""
    error_message = "The ID of the SSM Agent Security Group is empty, possibly not created."
  }

  assert {
    condition     = module.ssm_agent.launch_template_id != ""
    error_message = "The ID of the SSM Agent Launch Template is empty, possibly not created."
  }

  assert {
    condition     = module.ssm_agent.autoscaling_group_id != ""
    error_message = "The ID of the SSM Agent Autoscaling Group is empty, possibly not created."
  }

  assert {
    condition     = module.ssm_agent.role_id != ""
    error_message = "The ID of the SSM Agent Role is empty, possibly not created."
  }

}

run "validate_ssm_agent_data" {
  module {
    source = "./tests/test-harness"
  }

  variables {
    # These variables are based on using the values from `./examples/complete` module since we are using that for the integration tests.
    instance_name               = "mp-terraform-test${run.setup.random_number}"
    ssm_document_name_from_test = "SSM-SessionManagerRunShell"
    iam_role_name_from_test     = run.create_ssm_agent.role_id
  }

  # The EC2 Instance is not directly created since it is managed by the ASG + Launch Template.
  # Check that the EC2 instance is actually spun up after this integration test.
  assert {
    condition     = data.aws_instance.from_test.arn != ""
    error_message = "The SSM Agent EC2 instance does not exist."
  }
  assert {
    condition     = contains(["running", "pending"], data.aws_instance.from_test.instance_state)
    error_message = "The SSM Agent EC2 instance is not running or pending."
  }

  assert {
    condition     = tolist(data.aws_instance.from_test.root_block_device)[0].encrypted == true
    error_message = "The root block device of the SSM Agent EC2 instance is not encrypted."
  }


  assert {
    condition     = data.aws_ssm_document.from_test.content != ""
    error_message = "The created SSM document content is empty."
  }

  assert {
    condition     = can(regex("\"Effect\"\\s*:\\s*\"Allow\"", data.aws_iam_role.from_test.assume_role_policy))
    error_message = "The created IAM role policy must contain Effect: Allow"
  }

  assert {
    condition     = can(regex("\"Service\"\\s*:\\s*\"ec2\\.amazonaws\\.com\"", data.aws_iam_role.from_test.assume_role_policy))
    error_message = "The created IAM role policy must contain Service: ec2.amazonaws.com"
  }

  assert {
    condition     = can(regex("\"Action\"\\s*:\\s*\"sts:AssumeRole\"", data.aws_iam_role.from_test.assume_role_policy))
    error_message = "The created IAM role policy must contain Action: sts:AssumeRole"
  }
}
