#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

localstack wait -t 30

# Scenario specific tests
check "localstack-cli version" 'localstack --version | grep 3.3.0'
check "localstack image version" 'localstack status | grep "Docker image" | grep 3.3.0'
check "persist localstack data" "localstack config show | grep -w PERSISTENCE | grep -io True"

awslocal s3 mb s3://devcontainer-persisted-data
localstack stop && localstack start -d
localstack wait -t 30

check "data persisted" "awslocal s3api list-buckets | jq -e '.Buckets | any(.Name == \"devcontainer-persisted-data\")' "

# Report result
reportResults
