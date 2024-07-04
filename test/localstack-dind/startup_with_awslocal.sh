#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "distro" lsb_release -c | grep "jammy"
check "localstack status" localstack status
check "localstack stops" localstack stop
check "awslocal installed" type awslocal

# Report result
reportResults
