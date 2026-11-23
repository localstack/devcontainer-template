#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

check "lstk installed" lstk --version
check "docker is up" "docker info > /dev/null"
check "emulator not started" "! docker ps --format '{{.Names}}' | grep -q localstack"
check "localstack AWS profile written" "aws configure get endpoint_url --profile localstack | grep localhost.localstack.cloud:4566"

reportResults
