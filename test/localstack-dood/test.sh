#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Template specific tests
check "distro" 'lsb_release -c | grep jammy'
check "localstack status" lstk --non-interactive status

# Report result
reportResults
