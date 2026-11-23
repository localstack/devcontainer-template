#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "distro" lsb_release -c | grep "jammy"
check "localstack status" lstk --non-interactive status
check "localstack stops" lstk --non-interactive stop

# Report result
reportResults
