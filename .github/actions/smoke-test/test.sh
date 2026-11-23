#!/bin/bash
TEMPLATE_ID="$1"
SRC_DIR="/tmp/${TEMPLATE_ID}"
echo "Running Smoke Test"

ID_LABEL="test-container=${TEMPLATE_ID}"
devcontainer exec --workspace-folder "${SRC_DIR}" --id-label ${ID_LABEL} /bin/sh -c 'set -e && if [ -f "test-project/test.sh" ]; then cd test-project && if [ "$(id -u)" = "0" ]; then chmod +x test.sh; else sudo chmod +x test.sh; fi && ./test.sh; else ls -a; fi'

STATUS=$?

"$(dirname "$0")/../cleanup.sh" "${SRC_DIR}" "${ID_LABEL}"
exit ${STATUS}
