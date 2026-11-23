#!/bin/bash
# Removes everything a template test run created.
# Usage: cleanup.sh <workspace folder> <id label>
SRC_DIR="$1"
ID_LABEL="$2"
COMPOSE_PROJECT="$(basename "${SRC_DIR}")_devcontainer"

echo "🧹 Cleaning up ${SRC_DIR}"
# Stop the compose services first, so LocalStack removes the Lambda containers it started.
PROJECT_CONTAINERS=$(docker container ls -q -f "label=com.docker.compose.project=${COMPOSE_PROJECT}")
if [ -n "${PROJECT_CONTAINERS}" ] ; then
    docker stop -t 30 ${PROJECT_CONTAINERS} > /dev/null
fi
for filter in "label=${ID_LABEL}" "label=com.docker.compose.project=${COMPOSE_PROJECT}"; do
    CONTAINERS=$(docker container ls -aq -f "${filter}")
    if [ -n "${CONTAINERS}" ] ; then
        docker rm -f ${CONTAINERS} > /dev/null && echo "🧹 Removed containers matching ${filter}"
    fi
done
for NETWORK in $(docker network ls -q -f "label=com.docker.compose.project=${COMPOSE_PROJECT}"); do
    # Containers LocalStack started on the network, e.g. Lambda functions.
    ATTACHED=$(docker container ls -aq -f "network=${NETWORK}")
    if [ -n "${ATTACHED}" ] ; then
        docker rm -f ${ATTACHED} > /dev/null && echo "🧹 Removed containers attached to network ${NETWORK}"
    fi
    docker network rm "${NETWORK}" > /dev/null && echo "🧹 Removed network ${NETWORK}"
done
sudo rm -rf "${SRC_DIR}" && echo "🧹 Removed ${SRC_DIR}"
