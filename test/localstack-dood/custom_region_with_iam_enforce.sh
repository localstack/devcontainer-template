#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

waitForLocalStack

# Scenario specific tests
check "localstack status" lstk --non-interactive status
check "default region" 'lstk aws sqs create-queue --queue-name test-queue | grep eu-central-1'

lstk aws iam create-user --user-name test
lstk aws iam put-user-policy --user-name test --policy-name restrict-queue-list --policy-document "$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyAllQueue",
            "Effect": "Deny",
            "Action": [
                "sqs:ListQueues"
            ],
            "Resource": "arn:aws:sqs:*"
        }
    ]
}
EOF
)"
TMP_CREDS=$(lstk aws iam create-access-key --user-name test)
export AWS_ACCESS_KEY_ID=$(jq -r .AccessKey.AccessKeyId <<< $TMP_CREDS)
export AWS_SECRET_ACCESS_KEY=$(jq -r .AccessKey.SecretAccessKey <<< $TMP_CREDS)
check "access denied" "! lstk aws sqs list-queues"

# Report result
reportResults
