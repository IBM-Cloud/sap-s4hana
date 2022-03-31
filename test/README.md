# Creating Tests for Your Module

Your Terraform module is tested in this template using the Golang
[Terratest library](https://github.com/gruntwork-io/terratest) from Gruntwork.io.

Unit tests consist of running a validate and plan against the module and asserting known values
without running an apply to create infrastructure on an account. These tests are run on any PR.

Acceptance tests are tests that rely on an apply of the module creating real infrastructure to
perform tests against. In this mode, you can get all the values that would have been unknown with
only a plan, and also perform tests against the application layer of the deployment. These tests are
run when a PR against master is opened, or when creating a release (tag).

## TerraTest Helper Module

A helper module (tf-helper) is used in the test to help with setting up the test. It will help with
running and syncing the terraform plan and apply commands, so you don't have to worry about how many
times you call plan or apply. It provides resource helper methods to make it easier to get planned
and changed values. Will only run the tests that do not need an apply when in `-short` (PR) mode.
And it will automatically destroy resources spun up at the end of the test.

### Getting Started with Tf-Helper

To initialize tf-helper, you just need to hook it into the `TestMain` function like so:

```golang
func TestMain(m *testing.M) {
    terratest.TestMain(m, &terraform.Options{
        // required, directory where your module is
        // unless you have a sub-module, it should just be ".."
        TerraformDir: "..",

        // variables for you module, 
        Vars: map[string]interface{}{
            // pass in the Travis encrypted api key
            "ibmcloud_api_key":  os.Getenv("API_KEY"),

            // custom module vars below
            "vsi_name": "foobar",
        },
    })
}
```

The
[Terratest options](https://github.com/gruntwork-io/terratest/blob/master/modules/terraform/options.go#L40)
supplied to `TestMain` will become the `prime` options for the test. Each test file can only have
one set of `prime` options. These will be the options that are used for the plan and apply. If you
want to test more than one set of options, multiple variable sets, you should create additional test
files. Travis is set up to run all the test files in the `test/` directory. However, you may want to
see how existing infrastructure will change when a new set of variables are applied against it. You
can do this with migration plans.

### Creating Your First Test

Creating a unit test is straightforward, just run a plan and assert resource values:

```golang
func TestVSI(t *testing.T) {
    // Get the plan (plan struct from resulting terraform plan command)
    // tf-helper will only run the plan once, so no need to worry how
    // many times you call it in your test file
    plan := terratest.GetPlan(t)

    // Get the resources you want to assert against
    vsi1 := terratest.GetResourcePlannedValues(t, plan, "ibm_is_instance.vsi1")

    // Assert stuff
    assert.Equal(t, "cx2-2x4", vsi1["profile"])
    assert.NotEqual(t, "us-south-2", vsi1["zone"])
}
```

### Acceptance Test

Acceptance tests will run when a PR is opened against master. These are tests that create
infrastructure and allow you to run various tests against it. You can also get the output from the
apply to assert against.

In the test below, the public IP of the VSI created is used to ping and ensure that our
infrastructure was deployed successfully.

```golang
func TestVPCConnectivity(t *testing.T) {
    // does not matter how many times ApplyPlan is called in a test file, it 
    // will only run the Apply and create the infrastructure one time. Always
    // uses the `prime` options specified in TestMain
    terratest.ApplyPlan(t)

    // output from the terratest apply
    publicIp := terratest.Output(t, "public_ip")

    // This ping is an example, and should probably not be used in an actual test
    out, _ := exec.Command("ping", publicIp, "-c 5", "-i 3", "-w 10").Output()
    assert.NotContains(t, string(out), "0 received")
}
```

#### Testing Against State

Using version v1.2.0 of tf-helper allows you to also test the values of the state of
terraform after an apply. To get the state you just need to call `GetState`. This will first run
`terraform apply` and then `terraform show` to retrieve the resources from the local state file.
Once you have the state then you can run assertions against it. This works the same way as when
testing against plan data, however uses new functions that allow input of the state object. For
instance in the following example we use
`GetResourceValues` instead of `GetResourcePlannedValues`. See
[tf-helper](https://github.ibm.com/mathewss/tf-helper/tree/v1.2.0/modules/terratest#deep-values) for
more information. Like `GetPlan` and `Apply`, `GetState` is synchronized and will only run once per
test case.

```golang
func TestVSIValues(t *testing.T) {
    state := terratest.GetState(t)
    vsi1 := terratest.GetResourceValues(t, state, "ibm_is_instance.vsi1")

    assert.Equal(t, 4, int(vsi1["memory"].(float64)))
    assert.Equal(t, "running", vsi1["status"])
    assert.NotEmpty(t, vsi1["id"])
}
```

### Migration (Day 2) Plan Test

This is a more advanced test where you can test to see what would happen if new variables were used
in a Terraform Plan against the existing state (after an apply). Because this requires state, the
`prime` options are applied and infrastructure is created first. This test will only be run in non
`-short` mode.

Because you may want to run many different variable sets, each time `GetMigrationPlan` is called,
the Terraform command `plan` will be run.

```golang
func TestMigrationChange(t *testing.T) {
    // Get the migration plan, send in options with new variables
    // than were used in our `prime` (TestMain) options
    migrationPlan := terratest.GetMigrationPlan(t, &terraform.Options{
        TerraformDir: "..",
        Vars: map[string]interface{}{
            "ibmcloud_api_key":  os.Getenv("API_KEY"),
            "vsi_name": "bazbar",
        },
    })

    resource := "ibm_is_instance.vsi1"

    // Values after the apply
    before := terratest.GetResourceBeforeChange(t, migrationPlan, resource)

    // Values with our migration plan run against the state
    after := terratest.GetResourceAfterChange(t, migrationPlan, resource)

    // Assert some stuff
    assert.Equal(t, "vsi-sandbox-foobar", before["name"])
    assert.Equal(t, "vsi-sandbox-bazbar", after["name"])
}
```

### TF-Helper Resource Helpers

Using version v1.2.0 of tf-helper, it provides new methods to make testing child resources
easier. The method for retrieving resource from a plan (`GetPlannedResourceValues`) has been updated
to retrieve children resources when given the full path to them. For example:

To get the name of the primary network adapter from the instance before, you would need to first
cast the vsi's primary network interface to a slice of interfaces, get the first one, then cast
that to a map of interfaces.

```golang
    vsi1 := terratest.GetResourcePlannedValues(t, plan, "ibm_is_instance.vsi1")
    primaryNic := vsi1["primary_network_interface"]
    assert.Equal(t, "foobar", primaryNic.([]interface{})[0].(map[string]interface{})["name"])
```

With the upgraded get methods, you can provide the full path to the primary network interface and
be passed back the same map of interfaces you would have had to do all that work to get before.

```golang
    primaryNic := terratest.GetResourcePlannedValues(t, plan, "ibm_is_instance.vsi1.primary_network_interface")
    assert.Equal(t, "foobar", primaryNic["name"])
```

This will always give you back the first element's values of the path provided. If you need to
get the slice to test against, you can use the new method `GetResourcePlannedList`.

```golang
    primaryNic := terratest.GetResourcePlannedList(t, plan, "ibm_is_instance.vsi1.primary_network_interface")
    assert.Equal(t, "foobar", primaryNic[0]["name"])
```

The following assertions are all equivalent:

```golang
    plan := terratest.GetPlan(t)
    vsi1 := terratest.GetResourcePlannedValues(t, plan, "ibm_is_instance.vsi1")

    assert.Equal(t, "foobar", terratest.GetChildren(t, vsi1, "primary_network_interface")[0]["name"])
    assert.Equal(t, "foobar", terratest.GetFirstChild(t, vsi1, "primary_network_interface")["name"])
    assert.Equal(t, "foobar", terratest.GetResourcePlannedValues(t, plan, "ibm_is_instance.vsi1.primary_network_interface")["name"])
    assert.Equal(t, "foobar", terratest.GetResourcePlannedList(t, plan, "ibm_is_instance.vsi1.primary_network_interface")[0]["name"])
```

The methods for state and migration data have also been upgraded. See
[tf-helper](https://github.ibm.com/mathewss/tf-helper/tree/v1.2.0/modules/terratest#deep-values) for
more information.

### Multiple Variable Sets

**NOTE: When using multiple test packages, include the `-p 1` switch when executing `go test`.**

Because we want to be thorough with testing, we will want a way to test different variable sets
that will produce different outcomes. Subtleties like name changes might not need to be tested,
but if your module creates more or different resources based on variable input, we do want to
test for those.

There are a couple of different ways to do this, one is to create a package directory for each
variable set. This is ok, but it can lead to lots of folders, and take away from your directory
structure you might use for another meaning.

The recommendation is to use TestCases.

TestCases were introduced by tf-helper in v1.1.0. TestCases will let you define a structure with
tests that you want to run for a specific set of terraform options, without having to create new
packages.

With TestCases, you should not initialize the test with TestMain, instead that logic is handled
in each of run of a TestCase. Below is all you would need to create a test. Create additional
tests in the test case by adding Test functions to MyTestCase.

#### Use of TestCase

```golang
// This function will be the parent test for your sub-tests
// defined in your MyTestCase struct
func TestMyTestCase(t *testing.T) {

    // IMPORTANT: You MUST pass your test case as a pointer.
    terratest.RunTestCase(t, &MyTestCase{}, &terraform.Options{

        // required, directory where your module is
        // unless you have a sub-module, it should just be ".."
        TerraformDir: "..",

        // variables for your module,
        Vars: map[string]interface{}{
            // pass in the Travis encrypted api key
            "ibmcloud_api_key":  os.Getenv("API_KEY"),

            // custom module vars below
            "vsi_name": "foobar",
        },
    })
}

// Your test case should just be a new struct type
// feel free to add any fields you'd like to it.
type MyTestCase struct{}

// Create Tests for MyTestCase, the only difference from a `TestMain`
// type test is that the tests belong to the MyTestCase struct
func (m *MyTestCase) TestVSI(t *testing.T) {
    plan := terratest.GetPlan(t)

    // Get the resources you want to assert against
    vsi1 := terratest.GetResourcePlannedValues(t, plan, "ibm_is_instance.vsi1")

    // Assert stuff
    assert.Equal(t, "cx2-2x4", vsi1["profile"])
    assert.NotEqual(t, "us-south-2", vsi1["zone"])
}
```

Now when you run it the output will be slightly different. The tests in the TestCase
are treated as sub-tests.

```txt
--- PASS: TestMyTestCase (9.66s)
    --- PASS: TestMyTestCase/TestVSI (9.66s)
    ... Additional Tests from MyTestCase
--- <Next TestCase>
    ... Tests from <Next TestCase>
```

Create multiple test cases in a single file, or create a file for each test case. Go test will
not care how you do this. All `go test` will look for are functions that start with `Test`.
It's up to you and your team on how best to organize these TestCases for your module. Remember
though, if you use multiple packages you must include `-p 1` switch with `go test` when
executing.

#### Ordering TestCases

You may order your tests in your test case by defining the optional function `GetOrderedTests` on
the test case struct. It should accept no parameters and return a slice of function names. The names
returned will be first run in the order supplied, then any additional tests in the test case will be
run (with no guarantee of order) afterwards.

See
[Ordered TestCases](https://github.ibm.com/mathewss/tf-helper/tree/master/modules/terratest#ordered-testcases)
for more information.

## Terratest Resources

To see example tests, including ones in this readme, see the Sandbox link below.

- [TerraTest Helper](https://github.ibm.com/mathewss/tf-helper/tree/master/modules/terratest)
- [Sandbox Tests](https://github.ibm.com/mathewss/tf-sandbox/tree/master/test)
- [Terratest](https://github.com/gruntwork-io/terratest/tree/master/modules/terraform)
