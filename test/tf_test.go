package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"github.ibm.com/mathewss/tf-helper/modules/terratest"
)

// This skeleton uses TestCases and makes it easy to test with multiple variable sets
// and add ordering if needed. See more documentation at
// https://github.ibm.com/mathewss/tf-helper/tree/master/modules/terratest
// and also in the README.md for this directory.

func TestMyTestCase(t *testing.T) {
	terratest.RunTestCase(t, &MyTestCase{}, &terraform.Options{
		// Could be parent dir, or sub in parent
		TerraformDir: "..",

		// Variables used in module
		Vars: map[string]interface{}{
			// Generally the api key passed
			"ibmcloud_api_key": os.Getenv("API_KEY"),

			// Insert variables to test with here
			// Each test case can have one set of
			// prime options to run terraform
			// plan and apply with.

			// To test with another set of options,
			// create another test case.
			// Test cases maybe in the same directory
			// or in sub-directories, based on your
			// need and use case.

			// You may test multiple migrations of
			// the prime test case to see how
			// changes in variables will affect the
			// infrastructure that is applied.
		},
	})
}

// See https://github.ibm.com/workload-eng-services/tf-template-test for an example
// and usage of the tf-helper terratest helper module

type MyTestCase struct{}

func (tc *MyTestCase) TestMyResource(t *testing.T) {
	// See the README in this directory for examples of how to
	// get resources and test from the Terraform plan.
	assert.True(t, true)
}
