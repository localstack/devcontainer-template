#!/usr/bin/env bash
# Runs once after the dev container is created.
set -euo pipefail

config_dir="${HOME}/.config/lstk"
mkdir -p "${config_dir}"
ln -sfn "$(cd "$(dirname "$0")" && pwd)/config.toml" "${config_dir}/config.toml"

# Writes the `localstack` profile used by `aws` and the AWS SDKs (AWS_PROFILE=localstack).
lstk --non-interactive setup aws --force
