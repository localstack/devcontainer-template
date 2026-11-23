#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

waitForLocalStack

# Scenario specific tests
check "localstack image version" "curl -s http://localhost:4566/_localstack/health | jq -e '.version | startswith(\"2026.9.\")'"
check "persist localstack data" "docker inspect localstack-main | jq -e '.[0].Config.Env | index(\"PERSISTENCE=true\") != null'"

lstk aws s3 mb s3://devcontainer-persisted-data
lstk --non-interactive stop && lstk --non-interactive start --timeout 3m
waitForLocalStack

check "data persisted" "lstk aws s3api list-buckets | jq -e '.Buckets | any(.Name == \"devcontainer-persisted-data\")'"

# Report result
reportResults
