#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

waitForLocalStack
SCENARIO=$(basename -s .sh $0)

# Scenario specific tests
check "pod loaded resources" "lstk aws s3api list-buckets | jq -e '.Buckets | any(.Name == \"devcontainer-test\")'"

# Report result
reportResults
