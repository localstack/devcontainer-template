#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "distro" lsb_release -c | grep "jammy"
check "localstack not running" localstack status | grep stopped
check "awslocal installed" ! type awslocal

# Report result
reportResults
