#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Scenario specific tests
check "distro" lsb_release -c | grep "jammy"
check "awslocal" type awslocal
check "cdklocal" type cdklocal
check "pulumilocal" type pulumilocal
check "samlocal" type samlocal
check "tflocal" type tflocal
check "localstack stopped" localstack status; localstack status | grep stopped > /dev/null

# Report result
reportResults
