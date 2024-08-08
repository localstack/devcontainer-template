#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

localstack wait -t 30

# Scenario specific tests
check "localstack-cli version" 'localstack --version | grep 3.3.0'
check "localstack custom host reachable" curl -s http://my-host.localstack.cloud:4566/_localstack/health
check "localstack image version" "curl -s http://my-host.localstack.cloud:4566/_localstack/health | jq -e '.version | test(\"^3.3.[0-9].dev.*\")'"

# Report result
reportResults
