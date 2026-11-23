#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

waitForLocalStack

check "distro" "grep VERSION_CODENAME=noble /etc/os-release"
check "lstk installed" lstk --version
check "no legacy CLI or wrappers" "! command -v localstack && ! command -v awslocal && ! command -v tflocal && ! command -v cdklocal && ! command -v samlocal"
check "lstk targets the compose service" "test \"\${LSTK_ENDPOINT_URL}\" = http://localhost.localstack.cloud:4566"
check "lstk status over the endpoint" "lstk --non-interactive status"
check "lstk start is refused" "! lstk --non-interactive start"
check "image tag" "docker inspect localstack-main --format '{{.Config.Image}}' | grep -x 'localstack/localstack-pro:latest'"
check "localstack.cloud resolves to the service" "getent ahostsv4 localhost.localstack.cloud | grep -w 10.0.2.20"
check "lstk aws (replaces awslocal)" "lstk aws s3 mb s3://lstk-smoke && lstk aws s3 ls | grep lstk-smoke"
check "aws CLI uses the localstack profile" "aws s3 ls | grep lstk-smoke"
check "lambda reaches LocalStack over the shared network" "lambdaRoundTrip dood-smoke"

reportResults
