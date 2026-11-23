#!/bin/bash

FAILED=()

echoStderr()
{
    echo "$@" 1>&2
}

check() {
    LABEL=$1
    shift
    echo -e "\n🧪 Testing $LABEL"
    eval $@
    if [ $? -eq 0 ]; then
        echo "✅  Passed!"
        return 0
    else
        echoStderr "❌ $LABEL check failed."
        FAILED+=("$LABEL")
        return 1
    fi
}

reportResults() {
    if [ ${#FAILED[@]} -ne 0 ]; then
        echoStderr -e "\n💥  Failed tests: ${FAILED[@]}"
        exit 1
    else 
        echo -e "\n💯  All passed!"
        exit 0
    fi
}

# Replacement for `localstack wait`: polls `lstk status` until LocalStack is up (default timeout 60s)
waitForLocalStack() {
    local timeout=${1:-60}
    for _ in $(seq "$timeout"); do
        lstk --non-interactive status > /dev/null 2>&1 && return 0
        sleep 1
    done
    echoStderr "LocalStack did not become ready within ${timeout}s"
    return 1
}
