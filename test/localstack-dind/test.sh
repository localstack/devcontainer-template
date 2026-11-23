#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

check "distro" "grep VERSION_CODENAME=noble /etc/os-release"
check "lstk installed" lstk --version
check "no legacy CLI or wrappers" "! command -v localstack && ! command -v awslocal && ! command -v tflocal && ! command -v cdklocal && ! command -v samlocal"
check "lstk uses the template config" "readlink ~/.config/lstk/config.toml | grep -E '\.devcontainer/lstk/config\.toml$'"
check "emulator is running" "lstk --non-interactive status"
check "image tag" "docker inspect localstack-aws --format '{{.Config.Image}}' | grep -x 'localstack/localstack-pro:latest'"
check "state on the /data volume" "docker inspect localstack-aws --format '{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}' | grep -w '/data:/var/lib/localstack'"
check "lstk aws (replaces awslocal)" "lstk aws s3 mb s3://lstk-smoke && lstk aws s3 ls | grep lstk-smoke"
check "aws CLI uses the localstack profile" "aws s3 ls | grep lstk-smoke"
check "lambda runs in the inner docker" "lambdaRoundTrip dind-smoke"
check "lstk stop" "lstk --non-interactive stop && ! docker ps --format '{{.Names}}' | grep -x localstack-aws"

reportResults
