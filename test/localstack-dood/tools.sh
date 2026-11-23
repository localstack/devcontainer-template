#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# Scenario specific tests
check "distro" lsb_release -c | grep "jammy"
check "lstk" type lstk

# Report result
reportResults
