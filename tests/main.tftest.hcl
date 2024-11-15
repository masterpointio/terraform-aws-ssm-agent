variables {
  vpc_id = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]
  stage = "test"
  namespace = "mp"
  name = "ssm-agent"
  region = "us-east-1"
  availability_zones = ["us-east-1a"]
  nat_gateway_enabled = true
  ipv6_enabled = true
}

### TESTING INSTANCE and ARCHITECTURE COMPATIBILITY ###
# https://docs.aws.amazon.com/ec2/latest/instancetypes/instance-type-names.html
# https://aws.amazon.com/ec2/instance-types/

# Test valid x86_64 instance type
run "valid_x86_64_instance" {
  command = plan

  variables {
    instance_type = "t3.micro"
    architecture = "x86_64"
  }

  assert {
    condition     = local.is_instance_compatible
    error_message = "Expected instance type t3.micro to be compatible with x86_64 architecture"
  }
}

# Test valid arm64 instance type
run "valid_arm64_instance" {
  command = plan

  variables {
    instance_type = "t4g.micro"
    architecture = "arm64"
  }

  assert {
    condition     = local.is_instance_compatible
    error_message = "Expected instance type t4g.micro to be compatible with arm64 architecture"
  }
}

# Test invalid x86_64 instance type (using arm64 instance type)
run "invalid_x86_64_instance" {
  command = plan

  variables {
    instance_type = "t4g.micro"
    architecture = "x86_64"
  }

  expect_failures = [
    null_resource.validate_instance_type
  ]
}

# Test invalid arm64 instance type (using x86_64 instance type)
run "invalid_arm64_instance" {
  command = plan

  variables {
    instance_type = "t3.micro"
    architecture = "arm64"
  }

  expect_failures = [
    null_resource.validate_instance_type
  ]
}

# Test edge case, where the 'g' is defined as the instance family rather than the processor family
# It has 'g' in the name, but it's still an x86_64 instance type because the 'g' is the instance family
run "graphics_instance_arm_incompatiblity_edge_case" {
  command = plan

  variables {
    instance_type = "g3s.xlarge"
    architecture = "arm64"
  }

  expect_failures = [
    null_resource.validate_instance_type
  ]
}

# Test edge case, where the 'g' is defined as the instance family rather than the processor family
# It has 'g' in the name, but it still is compatible with x86_64 since the 'g' is the instance family
run "graphics_instance_x86_compatibility_edge_case" {
  command = plan

  variables {
    instance_type = "g4dn.xlarge"
    architecture = "x86_64"
  }

  assert {
    condition     = local.is_instance_compatible
    error_message = "Expected instance type g3s.xlarge to be compatible with x86_64 architecture"
  }
}
