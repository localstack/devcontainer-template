#!/bin/bash
TEMPLATE_ID="$1"

set -e

shopt -s dotglob

function remove_comments {
    sed -i -re 's/[[:blank:]]*(\/\/\s.*)//' ${1}
}

function merge {
    cp .devcontainer/devcontainer.json .devcontainer/devcontainer.json.bak
    remove_comments .devcontainer/devcontainer.json.bak

    jq -s ".[0] * .[1]" .devcontainer/devcontainer.json.bak ./inputs.json > .devcontainer/devcontainer.json
    cp -f .devcontainer/devcontainer.json .devcontainer/devcontainer.json.bak
    
    # Clean up unneeded keys
    printf -v tmp_str '.%s,' "${OPTIONS[@]}"
    jq "del($(echo "${tmp_str%,}"))" .devcontainer/devcontainer.json.bak > .devcontainer/devcontainer.json

    rm .devcontainer/devcontainer.json.bak
}

# Optional: test against a local checkout of the LocalStack Feature instead of
# the published one, e.g. LOCAL_FEATURE_DIR=../devcontainer-feature/src/localstack-cli
function use_local_feature {
    if [ -z "${LOCAL_FEATURE_DIR:-}" ] ; then
        return
    fi
    echo "(!) Using local LocalStack Feature from '${LOCAL_FEATURE_DIR}'"
    cp -R "${LOCAL_FEATURE_DIR}" "${SRC_DIR}/.devcontainer/localstack-cli"
    sed -i -e 's#"ghcr.io/localstack/devcontainer-feature/localstack-cli:[^"]*"#"./localstack-cli"#' "${SRC_DIR}/.devcontainer/devcontainer.json"
}

SRC_DIR="/tmp/${TEMPLATE_ID}"
cp -R "src/${TEMPLATE_ID}" "${SRC_DIR}"
LOCAL_FEATURE_DIR="${LOCAL_FEATURE_DIR:+$(cd "${LOCAL_FEATURE_DIR}" && pwd)}"

pushd "${SRC_DIR}"

# Configure templates only if `devcontainer-template.json` contains the `options` property.
OPTION_PROPERTY=( $(jq -r '.options' devcontainer-template.json) )

if [ "${OPTION_PROPERTY}" != "" ] && [ "${OPTION_PROPERTY}" != "null" ] ; then  
    OPTIONS=( $(jq -r '.options | keys[]' devcontainer-template.json) )

    if [ "${OPTIONS[0]}" != "" ] && [ "${OPTIONS[0]}" != "null" ] ; then
        echo "(!) Configuring template options for '${TEMPLATE_ID}'"
        for OPTION in "${OPTIONS[@]}"
        do
            OPTION_KEY="\${templateOption:$OPTION}"
            if [ -f inputs.json ] ; then
                OPTION_VALUE=$(jq -r ".${OPTION}" inputs.json)
            fi
            
            if [ "${OPTION_VALUE}" = "" ] || [ "${OPTION_VALUE}" = "null" ] ; then
                if [ "$(jq -r --arg o "${OPTION}" '.options[$o] | has("default")' devcontainer-template.json)" != "true" ] ; then
                    echo "Template '${TEMPLATE_ID}' is missing a default value for option '${OPTION}'"
                    exit 1
                fi
                OPTION_VALUE=$(jq -r ".options | .${OPTION} | .default" devcontainer-template.json)
            fi

            echo "(!) Replacing '${OPTION_KEY}' with '${OPTION_VALUE}'"
            OPTION_VALUE_ESCAPED=$(sed -e 's/[]\/$*.^[]/\\&/g' <<<"${OPTION_VALUE}")
            find ./ -type f -print0 | xargs -0 sed -i "s/${OPTION_KEY}/${OPTION_VALUE_ESCAPED}/g"

            unset OPTION_VALUE
        done
    fi
fi

if [ -f inputs.json ] ; then
    merge
fi

popd

use_local_feature

TEST_DIR="test/${TEMPLATE_ID}"
if [ -d "${TEST_DIR}" ] ; then
    echo "(*) Copying test folder"
    DEST_DIR="${SRC_DIR}/test-project"
    mkdir -p ${DEST_DIR}
    cp -Rp ${TEST_DIR}/* ${DEST_DIR}
    cp test/test-utils/test-utils.sh ${DEST_DIR}
fi

export DOCKER_BUILDKIT=1
if ! type devcontainer &> /dev/null ; then
    echo "(*) Installing @devcontainer/cli"
    npm install -g @devcontainers/cli
fi

echo "Building Dev Container"
ID_LABEL="test-container=${TEMPLATE_ID}"
devcontainer up --id-label ${ID_LABEL} --workspace-folder "${SRC_DIR}"
