#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Scenario specific tests
check "localstack-cli version" 'localstack --version | grep 3.5.0'
check "localstack image version" 'localstack status | grep "Docker image" | grep latest'
check "localstack is pro" "docker inspect localstack-main | jq -e '.[0].Config.Env | index(\"ACTIVATE_PRO=1\") != null'"

localstack wait -t 30
SCENARIO=$(basename -s .sh $0)
check "pod loaded resources" "awslocal s3api list-buckets | jq -e '.Buckets | any(.Name == \"devcontainer-test\")'"

# Report result
reportResults
