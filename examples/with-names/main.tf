provider "aws" {
  region = var.region
}

# Create VPC and subnets with specific names for demonstration
module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.1.0"

  namespace = var.namespace
  stage     = var.stage
  name      = "example-vpc"

  ipv4_primary_cidr_block          = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
}

module "subnets" {
  source    = "cloudposse/dynamic-subnets/aws"
  version   = "2.3.0"
  namespace = var.namespace
  stage     = var.stage
  name      = "example-subnets"

  availability_zones = var.availability_zones
  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  ipv4_cidr_block    = [module.vpc.vpc_cidr_block]
  ipv6_enabled       = var.ipv6_enabled
}

# Example 1: Using VPC and subnet IDs (traditional approach)
module "ssm_agent_with_ids" {
  source    = "../../"
  stage     = var.stage
  namespace = var.namespace
  name      = "ssm-with-ids"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.private_subnet_ids
}

# Example 2: Using VPC and subnet names (new functionality)
module "ssm_agent_with_names" {
  source    = "../../"
  stage     = var.stage
  namespace = var.namespace
  name      = "ssm-with-names"

  vpc_name = module.vpc.vpc_id_tag_name # This would be the Name tag value
  subnet_names = [
    # These would be the actual Name tag values of the subnets
    # In a real scenario, you'd know these names or get them from data sources
    "example-private-subnet-1",
    "example-private-subnet-2"
  ]

  depends_on = [module.subnets]
}

# Example 3: Mixed configuration (VPC by ID, subnets by name)
module "ssm_agent_mixed" {
  source    = "../../"
  stage     = var.stage
  namespace = var.namespace
  name      = "ssm-mixed"

  vpc_id = module.vpc.vpc_id
  subnet_names = [
    "example-private-subnet-1",
    "example-private-subnet-2"
  ]

  depends_on = [module.subnets]
}
