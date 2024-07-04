#!/bin/bash
TEMPLATE_ID="$1"
set -e

SCENARIOS=( $(jq -r 'keys[]' test/${TEMPLATE_ID}/scenarios.json) )

type devcontainer > /dev/null
if [ $? -ne 0 ] ; then
    export DOCKER_BUILDKIT=1
    echo "(*) Installing @devcontainer/cli"
    npm install -g @devcontainers/cli
fi

for SCENARIO in ${SCENARIOS[@]}; do
    $(dirname $0)/build.sh ${TEMPLATE_ID} ${SCENARIO}
    $(dirname $0)/test.sh ${TEMPLATE_ID} ${SCENARIO}
done
