#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

check "distro" "grep VERSION_CODENAME=bookworm /etc/os-release"
check "pinned image tag" "docker inspect localstack-aws-2026.10 --format '{{.Config.Image}}' | grep -x 'localstack/localstack-pro:2026.10'"
check "PERSISTENCE passed to the emulator" "docker inspect localstack-aws-2026.10 --format '{{join .Config.Env \" \"}}' | grep -w PERSISTENCE=true"
check "volume path is /data" "lstk volume path | grep -x /data"
check "create bucket" "aws s3 mb s3://persisted-bucket"
check "lstk restart" "lstk --non-interactive restart"
check "bucket survives restart" "aws s3 ls | grep persisted-bucket"

reportResults
