#!/bin/bash
TEMPLATE_ID="$1"
SCENARIO="$2"
SRC_DIR="/tmp/${TEMPLATE_ID}-${SCENARIO}"

set -e

shopt -s dotglob

function remove_comments {
    sed -i -re 's/[[:blank:]]*(\/\/\s.*)//' ${1}
}

function merge {
    cp .devcontainer/devcontainer.json .devcontainer/devcontainer.json.bak
    remove_comments .devcontainer/devcontainer.json.bak

    if [ -f inputs.json ] ; then
        jq -s ".[0] * .[1]" .devcontainer/devcontainer.json.bak ./inputs.json > .devcontainer/devcontainer.json
        cp -f .devcontainer/devcontainer.json .devcontainer/devcontainer.json.bak
    fi

    jq -s ".[0] * .[1].${SCENARIO}" .devcontainer/devcontainer.json.bak test-project/scenarios.json > .devcontainer/devcontainer.json
    cp -f .devcontainer/devcontainer.json .devcontainer/devcontainer.json.bak
    
    # Clean up unneeded keys
    printf -v tmp_str '.%s,' "${OPTIONS[@]}"
    jq "del($(echo "${tmp_str%,}"))" .devcontainer/devcontainer.json.bak > .devcontainer/devcontainer.json

    rm .devcontainer/devcontainer.json.bak
}

function gen_config {
    echo "(*) Generating config files"
    # Configure templates only if `devcontainer-template.json` contains the `options` property.
    OPTIONS=( $(jq -r '.options | keys[]' devcontainer-template.json) )

    if [ "${OPTIONS[0]}" != "" ] && [ "${OPTIONS[0]}" != "null" ] ; then
        echo "(!) Configuring template options for '${TEMPLATE_ID}-${SCENARIO}'"
        for OPTION in "${OPTIONS[@]}"
        do
            OPTION_KEY="\${templateOption:$OPTION}"

            OPTION_VALUE=$( jq -r ".${SCENARIO}.${OPTION}" test-project/scenarios.json)

            if ( [ "${OPTION_VALUE}" = "" ] || [ "${OPTION_VALUE}" = "null" ] ) && [ -f inputs.json ] ; then
                OPTION_VALUE=$(jq -r ".${OPTION}" inputs.json)
            fi
            
            if [ "${OPTION_VALUE}" = "" ] || [ "${OPTION_VALUE}" = "null" ] ; then
                OPTION_VALUE=$(jq -r ".options | .${OPTION} | .default" devcontainer-template.json)
            fi

            # For empty default values use " "
            if [ "${OPTION_VALUE}" = "" ] || [ "${OPTION_VALUE}" = "null" ] ; then
                echo "Template '${TEMPLATE_ID}-${SCENARIO}' is missing a default value for option '${OPTION}'"
                exit 1
            fi

            echo "(!) Replacing '${OPTION_KEY}' with '${OPTION_VALUE}'"
            OPTION_VALUE_ESCAPED=$(sed -e 's/[]\/$*.^[]/\\&/g' <<<"${OPTION_VALUE}")
            find ./ -type f -print0 | xargs -0 sed -i "s/${OPTION_KEY}/${OPTION_VALUE_ESCAPED}/g"
            
            if [ "${OPTION}" == "volumePath" ] ; then
                mkdir -p ${SRC_DIR}/${OPTION_VALUE}
            fi

            unset OPTION_VALUE
        done
        
        merge
    fi
}

function create_scenario {
    cp -R "src/${TEMPLATE_ID}" "${SRC_DIR}"

    TEST_DIR="test/${TEMPLATE_ID}"
    if [ -d "${TEST_DIR}" ] ; then
        echo "(*) Copying test folder"
        DEST_DIR="${SRC_DIR}/test-project"
        mkdir -p ${DEST_DIR}
        cp -p ${TEST_DIR}/${SCENARIO}.sh ${TEST_DIR}/scenarios.json ${DEST_DIR}
        cp test/test-utils/test-utils.sh ${DEST_DIR}
    fi

    pushd "${SRC_DIR}"

    gen_config

    popd

    echo
    echo "🏗️ Building Dev Container - ${SCENARIO}"
    ID_LABEL="test-container=${TEMPLATE_ID}-${SCENARIO}"
    devcontainer up --id-label ${ID_LABEL} --workspace-folder "${SRC_DIR}" && echo "🚀 Launched container."
}

create_scenario
