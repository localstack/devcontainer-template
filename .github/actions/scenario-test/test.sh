#!/bin/bash
TEMPLATE_ID="$1"
SCENARIO="$2"

set -e

function run_scenario {
    local SRC_DIR="/tmp/${TEMPLATE_ID}-${SCENARIO}"
    local ID_LABEL="test-container=${TEMPLATE_ID}-${SCENARIO}"
    devcontainer exec --workspace-folder "${SRC_DIR}" --id-label ${ID_LABEL} /bin/sh -c "set -e && if [ -f \"test-project/${SCENARIO}.sh\" ]; then cd test-project && if [ \"$(id -u)\" = \"0\" ]; then chmod +x ${SCENARIO}.sh; else sudo chmod +x ${SCENARIO}.sh; fi && ./${SCENARIO}.sh; else ls -a; fi"
}

echo
echo "🔍 Running Scenario Test - ${SCENARIO}"
run_scenario

