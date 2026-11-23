#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

waitForLocalStack

check "custom host" "curl -fs http://my-host.localstack.cloud:4566/_localstack/health"
check "lstk status over the custom host" "lstk --non-interactive status"
check "profile uses the custom host" "aws configure get endpoint_url --profile localstack | grep my-host.localstack.cloud:4566"
check "default region" "aws sqs create-queue --queue-name region-queue | grep eu-central-1"
check "IAM is enforced" "iamDenyRoundTrip devcontainer-test"

reportResults
