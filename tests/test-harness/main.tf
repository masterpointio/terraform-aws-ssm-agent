terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_ssm_document" "from_test" {
  name = var.ssm_document_name_from_test
}

data "aws_iam_role" "from_test" {
  name = var.iam_role_name_from_test
}

data "aws_instance" "from_test" {
  filter {
    name   = "tag:Name"
    values = [var.instance_name]
  }
}
