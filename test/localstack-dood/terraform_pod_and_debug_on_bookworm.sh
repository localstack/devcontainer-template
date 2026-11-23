#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

POD=devcontainer-template-ci-dood

waitForLocalStack

check "distro" "grep VERSION_CODENAME=bookworm /etc/os-release"
check "log level is trace" "curl -s ${LOCALSTACK_URL}/_localstack/diagnose | jq -r '.config.LS_LOG' | grep -x trace"
check "lstk terraform over the endpoint (replaces tflocal)" "terraformRoundTrip dood-tf-bucket"
check "seed and save pod" "aws s3 mb s3://pod-bucket && lstk --non-interactive snapshot save pod:${POD}"
check "restart the localstack service" "docker restart localstack-main && waitForLocalStack"
check "pod auto-loaded on start" "timeout 60 bash -c 'until aws s3 ls | grep -q pod-bucket; do sleep 2; done'"
lstk --non-interactive snapshot remove pod:${POD} --force

reportResults
