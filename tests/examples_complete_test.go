package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/complete",
		Upgrade:      true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	sgId := terraform.Output(t, terraformOptions, "security_group_id")

	// Verify we're getting back the outputs we expect
	assert.NotEmpty(t, sgId)

	// Run `terraform output` to get the value of an output variable
	bucketName := terraform.Output(t, terraformOptions, "session_logging_bucket_id")

	// Verify we're getting back the outputs we expect
	assert.Contains(t, bucketName, "-logs")
}
