#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

waitForLocalStack

check "distro" "grep VERSION_CODENAME=jammy /etc/os-release"
check "pinned image tag" "docker inspect localstack-main --format '{{.Config.Image}}' | grep -x 'localstack/localstack-pro:2026.10'"
check "create bucket" "aws s3 mb s3://persisted-bucket"
check "restart the localstack service" "docker restart localstack-main && waitForLocalStack"
check "bucket survives restart" "aws s3 ls | grep persisted-bucket"
check "state written to the volume folder" "test -n \"\$(ls -A ../.devcontainer/volume)\""

reportResults
