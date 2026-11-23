#!/usr/bin/env bash
# Runs on every dev container start. Usage: post-start.sh <true|false>
set -uo pipefail

if [ "${1:-true}" != "true" ]; then
    echo "LocalStack auto-start is off. Run 'lstk start' to start it."
    exit 0
fi

echo "Waiting for the Docker daemon..."
if ! timeout 60 bash -c 'until docker info > /dev/null 2>&1; do sleep 1; done'; then
    echo "The Docker daemon did not come up within 60s. Run 'lstk start' once it is ready." >&2
    exit 1
fi

# The first start pulls the LocalStack image, so allow more than the 60s default.
LSTK_STARTUP_TIMEOUT="${LSTK_STARTUP_TIMEOUT:-5m}" lstk --non-interactive start
status=$?

if [ "${status}" -ne 0 ] && [ -z "${LOCALSTACK_AUTH_TOKEN:-}" ]; then
    echo "LocalStack did not start and LOCALSTACK_AUTH_TOKEN is not set."
    echo "Set it on the host and rebuild the container, or run 'lstk login' and then 'lstk start'."
    exit 0
fi
exit "${status}"
