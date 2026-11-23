#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

waitForLocalStack

# Scenario specific tests
check "localstack custom host reachable" curl -s http://my-host.localstack.cloud:4566/_localstack/health
check "localstack image version" "curl -s http://my-host.localstack.cloud:4566/_localstack/health | jq -e '.version | startswith(\"2026.9.\")'"

# Report result
reportResults
