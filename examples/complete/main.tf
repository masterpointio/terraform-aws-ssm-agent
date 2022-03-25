provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.26.1"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.39.3"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = var.nat_gateway_enabled
  nat_instance_enabled = !var.nat_gateway_enabled
}

module "ssm_agent" {
  source     = "../../"
  stage      = var.stage
  namespace  = var.namespace
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.private_subnet_ids
  user_data  = <<EOT
#!/bin/bash
# NOTE: Since we're using a latest Amazon Linux AMI, we shouldn't need this,
# but we'll update it to be sure.
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
echo 'export HELLO_WORLD="Hello World!"' >> ~/.bash_profile
EOT
}
