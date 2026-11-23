#!/usr/bin/env bash
# Runs on every dev container start. LocalStack itself runs as the localstack
# service in docker-compose.yml; lstk reaches it through LSTK_ENDPOINT_URL.
set -uo pipefail

echo "Waiting for LocalStack at ${LSTK_ENDPOINT_URL}..."
if timeout 120 bash -c 'until curl -fs "${LSTK_ENDPOINT_URL}/_localstack/health" > /dev/null; do sleep 2; done'; then
    lstk --non-interactive status
    exit 0
fi

echo "LocalStack is not reachable at ${LSTK_ENDPOINT_URL}."
if [ -z "${LOCALSTACK_AUTH_TOKEN:-}" ]; then
    echo "The localstack service needs LOCALSTACK_AUTH_TOKEN. Set it on the host and rebuild the container."
fi
echo "Check the service logs with: docker logs localstack-main"
exit 0
