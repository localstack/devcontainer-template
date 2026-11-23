#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

check "distro" "grep VERSION_CODENAME=jammy /etc/os-release"
check "emulator is running" "lstk --non-interactive status"
check "lstk terraform (replaces tflocal)" "terraformRoundTrip dind-tf-bucket"
check "lstk cdk (replaces cdklocal)" "cdkRoundTrip DindCdkStack"
check "lstk sam (replaces samlocal)" "samRoundTrip dind-sam-stack"

reportResults
