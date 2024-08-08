#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Scenario specific tests
check "distro" lsb_release -c | grep "bookworm"
check "localstack running" localstack status; localstack status | grep running > /dev/null
localstack wait -t 30
check "debug enabled" "curl -s http://localhost:4566/_localstack/diagnose; echo"
check "debug enabled" "curl -s http://localhost:4566/_localstack/diagnose | jq -r '.config.LS_LOG' | grep trace"

# Report result
reportResults
