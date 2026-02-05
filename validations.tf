# Validation using terraform_data to halt execution if requirements aren't met
resource "terraform_data" "vpc_subnet_validation" {
  count = local.enabled ? 1 : 0

  lifecycle {
    precondition {
      condition     = var.vpc_name != null || var.vpc_id != null
      error_message = "Either vpc_name or vpc_id must be provided."
    }

    precondition {
      condition     = length(var.subnet_names) > 0 || length(var.subnet_ids) > 0
      error_message = "Either subnet_names or subnet_ids must be provided."
    }
  }
}

# Warning checks for VPC and subnet configuration (non-blocking)
# Note: check blocks don't support count, so conditions include enabled check
check "vpc_subnet_warnings" {
  assert {
    condition     = !local.enabled || !(var.vpc_name != null && var.vpc_id != null)
    error_message = "Both vpc_name and vpc_id are provided. When vpc_name is specified, vpc_id will be ignored."
  }

  assert {
    condition     = !local.enabled || !(length(var.subnet_names) > 0 && length(var.subnet_ids) > 0)
    error_message = "Both subnet_names and subnet_ids are provided. When subnet_names are specified, subnet_ids will be ignored."
  }
}
