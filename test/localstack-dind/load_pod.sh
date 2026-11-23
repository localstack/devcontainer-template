#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

POD=devcontainer-template-ci-dind

check "distro" "grep VERSION_CODENAME=resolute /etc/os-release"
check "AUTO_LOAD_POD passed to the emulator" "docker inspect localstack-aws --format '{{join .Config.Env \" \"}}' | grep -w AUTO_LOAD_POD=${POD}"
check "seed and save pod" "aws s3 mb s3://pod-bucket && lstk --non-interactive snapshot save pod:${POD}"
check "lstk restart" "lstk --non-interactive restart"
check "pod auto-loaded on start" "timeout 60 bash -c 'until aws s3 ls | grep -q pod-bucket; do sleep 2; done'"
lstk --non-interactive snapshot remove pod:${POD} --force

reportResults
