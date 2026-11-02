terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.7"
    }
  }
}
