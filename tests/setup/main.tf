terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_integer" "random_number" {
  min = 1
  max = 9999
}

output "random_number" {
  value       = random_integer.random_number.result
  description = "Random number between 1 and 9999"
}
