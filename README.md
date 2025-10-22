# Firebase Test Lab GitHub Action

A GitHub Action to test mobile applications (Android) using Firebase Test Lab.

<br>

## Introduction

Testing mobile applications can be a challenge. With Firebase Test Lab, testing becomes much easier whether it's validating new changes on a continuous integration (CI) pipeline or tracking down bugs on specific devices. This GitHub Action automates the setup of the gcloud command line tool and provides an easy interface to start testing quickly.

<br>

## Pre-requisites

1. `Service Account`: A service account is a special kind of account with specific permissions to authenticate with the Cloud Platform when used on a virtual machine for continuous integration.

2. `ARG SPEC`: lists out all of the configurations for Firebase Test Lab. You can specify the test APK, filter the tests, select virtual or physical devices and indicate the type of test to perform.

<br>

## Usage
workflows/main.yml (with arguments):

```yaml
name: Android CI
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      # Check out the repository
      - uses: actions/checkout@v2

      # Run the Firebase Test Lab Action
      - name: Run tests on Firebase Test Lab
        uses: devapro/fb-test-lab-action@v0.4
        with:
          arg-spec: >-
            --type=instrumentation
            --timeout=40m
            --app=build/debug.apk
            --test=build/debug-androidTest.apk
            --project=[your firebase project]
            --results-bucket=[your bucket]
            --use-orchestrator
            --device=model=MediumPhone.arm,version=31,locale=en
            --client-details=matrixLabel="Android UI"
            --num-flaky-test-attempts=1
            --num-uniform-shards=2
        env:
          SERVICE_ACCOUNT: ${{ secrets.SERVICE_ACCOUNT }}
```

**Important Notes:**
- Use `>-` for multiline YAML strings to fold lines into a single string
- Do NOT include `--arg-spec` in your arguments - this is the GitHub Actions input name, not a gcloud flag
- Arguments are passed directly to `gcloud firebase test android run`
- All standard gcloud firebase test android run flags are supported

<br>

The following usage comes with additional instructions regarding the input and environment variables that can be found in the [Simple Usage Documentation](/docs/SIMPLE_USAGE.md).

Currently, this GitHub Action only runs Android tests. Support for iOS coming soon.

<br>

## Local Testing

Before deploying changes to the action, you can test it locally using the `test.sh` script:

```bash
# Make sure you have a service_account.json file (never commit this!)
# Run the test script with your arguments
./test.sh "--type=instrumentation --timeout=30m --app=path/to/app.apk --test=path/to/test.apk --device=model=Pixel2,version=28"
```

The script will build the Docker image and run the action locally with your service account and test parameters.

<br>

## Inputs

#### `arg-spec`

Configuration for Firebase Test Lab. **Required**

#### `SERVICE_ACCOUNT`

Copy-paste the content of the JSON-formatted service account file in GitHub's secret variables in settings. **Required**

<br>

## Outputs

#### `FTL_REPORT_URL`

URL of Firebase test results report

#### `FTL_GCP_URL`

URL of Google clound tests raw results

#### `FTL_ERROR_MESSAGE`

Error message, if action can't find Firebase or Google Cloud url

#### `FTL_TEST_STATUS`

Status of action. Action finished always with code 0, but code of test command is saved in this output variable

## Contributing

Are you facing an issue? Have some questions? Would like to implement a new feature? Learn more about our [contributing guidelines](CONTRIBUTING.md).

<br>

## Licence

The project is released under the [MIT License](LICENSE).