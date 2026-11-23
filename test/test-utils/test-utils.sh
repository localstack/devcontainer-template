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

# --- LocalStack helpers shared by both templates ---

LOCALSTACK_URL="${LSTK_ENDPOINT_URL:-http://localhost.localstack.cloud:4566}"

waitForLocalStack() {
    timeout "${1:-180}" bash -c "until curl -fs ${LOCALSTACK_URL}/_localstack/health > /dev/null; do sleep 2; done"
}

# Creates a Python Lambda function, invokes it and checks the response.
# Exercises the Docker wiring LocalStack needs to run function containers.
lambdaRoundTrip() {
    local name="$1" dir
    dir=$(mktemp -d)
    cat > "${dir}/index.py" <<'PY'
def handler(event, context):
    return {"message": "hello from " + event.get("name", "lambda")}
PY
    (cd "${dir}" && zip -q function.zip index.py) || return 1
    aws lambda create-function --function-name "${name}" --runtime python3.12 --handler index.handler \
        --role arn:aws:iam::000000000000:role/lambda-role --zip-file "fileb://${dir}/function.zip" > /dev/null || return 1
    aws lambda wait function-active-v2 --function-name "${name}" || return 1
    aws lambda invoke --function-name "${name}" --cli-binary-format raw-in-base64-out \
        --payload '{"name": "devcontainer"}' "${dir}/out.json" > /dev/null || return 1
    cat "${dir}/out.json"; echo
    grep -q "hello from devcontainer" "${dir}/out.json"
}

# Deploys an S3 bucket with `lstk terraform` (replaces tflocal).
terraformRoundTrip() {
    local bucket="$1" dir
    dir=$(mktemp -d)
    cat > "${dir}/main.tf" <<EOF
resource "aws_s3_bucket" "this" {
  bucket = "${bucket}"
}
EOF
    (
        cd "${dir}" &&
        lstk terraform init -input=false > /dev/null &&
        lstk terraform apply -auto-approve -input=false &&
        aws s3api head-bucket --bucket "${bucket}" &&
        lstk tf destroy -auto-approve -input=false > /dev/null
    )
}

# Deploys an SQS queue with `lstk cdk` (replaces cdklocal).
cdkRoundTrip() {
    local stack="$1" dir
    dir=$(mktemp -d)
    cat > "${dir}/app.js" <<'EOF'
const cdk = require("aws-cdk-lib");
const sqs = require("aws-cdk-lib/aws-sqs");
const app = new cdk.App();
const stack = new cdk.Stack(app, process.env.STACK_NAME);
new sqs.Queue(stack, "Queue", { queueName: process.env.STACK_NAME + "-queue" });
EOF
    echo '{"app": "node app.js"}' > "${dir}/cdk.json"
    (
        cd "${dir}" &&
        npm init -y > /dev/null &&
        npm install --no-audit --no-fund aws-cdk-lib constructs > /dev/null &&
        export STACK_NAME="${stack}" &&
        lstk cdk bootstrap &&
        lstk cdk deploy --require-approval never &&
        aws sqs get-queue-url --queue-name "${stack}-queue"
    )
}

# Deploys a Lambda function with `lstk sam` (replaces samlocal).
samRoundTrip() {
    local stack="$1" dir
    dir=$(mktemp -d)
    mkdir -p "${dir}/src"
    cat > "${dir}/src/index.py" <<'PY'
def handler(event, context):
    return {"message": "hello from sam"}
PY
    cat > "${dir}/template.yaml" <<'EOF'
AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31
Resources:
  HelloFunction:
    Type: AWS::Serverless::Function
    Properties:
      Runtime: python3.12
      Handler: index.handler
      CodeUri: src/
Outputs:
  FunctionName:
    Value: !Ref HelloFunction
EOF
    (
        cd "${dir}" &&
        lstk sam deploy --stack-name "${stack}" --resolve-s3 --capabilities CAPABILITY_IAM \
            --no-confirm-changeset --no-fail-on-empty-changeset &&
        fn=$(aws cloudformation describe-stacks --stack-name "${stack}" \
            --query "Stacks[0].Outputs[?OutputKey=='FunctionName'].OutputValue" --output text) &&
        aws lambda wait function-active-v2 --function-name "${fn}" &&
        aws lambda invoke --function-name "${fn}" out.json > /dev/null &&
        grep -q "hello from sam" out.json
    )
}

# Checks that a principal limited by an IAM deny policy is refused.
iamDenyRoundTrip() {
    local user="$1" creds
    aws iam create-user --user-name "${user}" > /dev/null || return 1
    aws iam put-user-policy --user-name "${user}" --policy-name deny-list-queues --policy-document '{
        "Version": "2012-10-17",
        "Statement": [{"Effect": "Deny", "Action": "sqs:ListQueues", "Resource": "*"}]
    }' || return 1
    creds=$(aws iam create-access-key --user-name "${user}") || return 1
    local out
    out=$(AWS_ACCESS_KEY_ID=$(jq -r .AccessKey.AccessKeyId <<< "${creds}") \
        AWS_SECRET_ACCESS_KEY=$(jq -r .AccessKey.SecretAccessKey <<< "${creds}") \
        aws sqs list-queues 2>&1)
    echo "${out}"
    grep -q -E 'AccessDenied|not authorized' <<< "${out}"
}
