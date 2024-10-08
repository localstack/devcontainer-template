#!/bin/bash
TEMPLATE_ID="$1"
ALL_RESULTS="  ================== 📋 TEST REPORT ==================\n"
EXIT_CODE=0

set +e

function reportAllScenarioResults {
    if [ ${2} -eq 0 ] ; then
        RES="✅ Passed:\t"
    else
        RES="❌ Failed:\t"
        EXIT_CODE=1
    fi
    ALL_RESULTS="$ALL_RESULTS\n$RES'${1}'"
}

function cleanup {
    # Clean up
    echo "🧹 Cleaning up..."
    local ID_LABEL=${2}
    CONTAINER_ID=$(docker container ls -f "label=${ID_LABEL}" -q)
    if [ "${CONTAINER_ID:-x}" != "x" ]; then
        docker rm -f "${CONTAINER_ID}" > /dev/null && echo "🧹 Removing container ${CONTAINER_ID}"
        echo "🧹 Removing container localstack-main (if exists)" && docker rm -f "localstack-main" &> /dev/null
    fi
    echo "🧹 Removing container network ${ID_LABEL/*=/}_devcontainer_ls (if exists)" && docker network rm -f "${ID_LABEL/*=/}_devcontainer_ls" > /dev/null
    sudo rm -rf "${1}" && echo "🧹 Removing scenario files ${SCENARIO}"
}

function no_scenarios {
    echo
    echo "(!) No scenarios collected. Exiting. Bye! 👋"
    exit
}

echo "⏱️ Scenario tests - ${TEMPLATE_ID}"
echo -n "(*) Collecting scenarios..."

if ! [ -f test/${TEMPLATE_ID}/scenarios.json ]; then
    no_scenarios
fi

SCENARIOS=( $(jq -r 'keys[]' test/${TEMPLATE_ID}/scenarios.json) )

if [ ${#SCENARIOS[@]} -eq 0 ] ; then
    no_scenarios
fi

echo "found ${#SCENARIOS[@]}"
echo
printf '%s\n' "${SCENARIOS[@]}"
echo 

type devcontainer &> /dev/null
if [ $? -ne 0 ] ; then
    export DOCKER_BUILDKIT=1
    set -e
    echo "(*) Installing @devcontainer/cli"
    npm install -g @devcontainers/cli
    set +e
fi

for SCENARIO in ${SCENARIOS[@]}; do
    ID_LABEL="test-container=${TEMPLATE_ID}-${SCENARIO}"
    SRC_DIR="/tmp/${TEMPLATE_ID}-${SCENARIO}"

    echo
    echo "🔄  Running scenario - ${SCENARIO}"
    $(dirname $0)/build.sh ${TEMPLATE_ID} ${SCENARIO} && \
    $(dirname $0)/test.sh ${TEMPLATE_ID} ${SCENARIO}
    reportAllScenarioResults ${SCENARIO} $?
    cleanup ${SRC_DIR} ${ID_LABEL}
    echo
done

echo -e "${ALL_RESULTS}"
exit ${EXIT_CODE}