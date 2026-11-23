#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

check "emulator is running" "lstk --non-interactive status"
check "default region" "aws sqs create-queue --queue-name region-queue | grep eu-central-1"
check "IAM is enforced" "iamDenyRoundTrip devcontainer-test"
check "log level is trace" "curl -s ${LOCALSTACK_URL}/_localstack/diagnose | jq -r '.config.LS_LOG' | grep -x trace"

reportResults
