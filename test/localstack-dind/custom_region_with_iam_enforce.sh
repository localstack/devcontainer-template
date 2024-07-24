#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

localstack wait -t 30

# Scenario specific tests
check "localstack version" localstack --version
check "default region" awslocal sqs create-queue --queue-name test-queue | grep eu-central-1

awslocal iam create-user --user-name test
awslocal iam put-user-policy --user-name test --policy-name restrict-queue-list --policy-document "$(cat <<EOF
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
TMP_CREDS=$(awslocal iam create-access-key --user-name test)
export AWS_ACCESS_KEY_ID=$(jq -r .AccessKey.AccessKeyId <<< $TMP_CREDS)
export AWS_SECRET_ACCESS_KEY=$(jq -r .AccessKey.SecretAccessKey <<< $TMP_CREDS)
check "access denied" "! awslocal sqs list-queues"

# Report result
reportResults
