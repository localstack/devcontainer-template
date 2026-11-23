
# LocalStack Docker-outside-of-Docker (localstack-dood)

Runs LocalStack as a Docker Compose service next to the dev container. lstk talks to it over the shared network.

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | Ubuntu or Debian version of the base image: | string | noble |
| version | LocalStack image tag (localstack/localstack-pro): | string | latest |
| logLevel | LocalStack log level (LS_LOG): | string | info |
| debug | Enable LocalStack debug mode (DEBUG): | boolean | false |
| persistence | Persist LocalStack state across restarts (PERSISTENCE): | boolean | false |
| enforceIam | Enforce IAM policies (ENFORCE_IAM): | boolean | false |
| loadPods | Cloud Pods to load at start-up, comma-separated (AUTO_LOAD_POD): | string | - |
| defaultRegion | Default AWS region for the AWS CLI and SDKs: | string | us-east-1 |
| networkName | Docker network shared by LocalStack, the dev container and Lambda containers: | string | ls |
| networkCidr | LocalStack network CIDR: | string | 10.0.2.0/24 |
| ipAddress | LocalStack IP address (inside the network CIDR): | string | 10.0.2.20 |
| host | LocalStack hostname and port (LOCALSTACK_HOST): | string | localhost.localstack.cloud:4566 |
| volumePath | Host folder for LocalStack state, relative to .devcontainer/: | string | ./.volume |

This Template runs LocalStack as a separate `localstack` service in Docker Compose, next to the dev container, using the host's Docker daemon.
Both containers share a Docker network, and LocalStack's DNS server resolves `localhost.localstack.cloud` to the LocalStack container.
The Template adds the [LocalStack DevContainer Feature](https://github.com/localstack/devcontainer-feature) for [`lstk`](https://docs.localstack.cloud/aws/developer-tools/running-localstack/lstk/), the AWS CLI Feature and the docker-outside-of-docker Feature.

## Auth token

Set `LOCALSTACK_AUTH_TOKEN` on the host before you build the container.
Docker Compose passes it to the `localstack` service and the dev container. It is never written into your files.
See the [auth token documentation](https://docs.localstack.cloud/aws/getting-started/auth-token/).

## How it works

| File | Purpose |
| --- | --- |
| `.devcontainer/docker-compose.yml` | The `localstack` and `app` services and their shared network. |
| `.devcontainer/.env` | LocalStack variables for the `localstack` service. |
| `.devcontainer/Dockerfile` | Base image of the dev container. |
| `.devcontainer/devcontainer.json` | Features and lifecycle commands. |
| `.devcontainer/lstk/post-start.sh` | Waits for LocalStack and prints `lstk status`. |

Docker Compose owns the LocalStack container, not `lstk`.
`LSTK_ENDPOINT_URL` points `lstk` at the `localstack` service, so `lstk status`, `lstk aws`, `lstk terraform`, `lstk cdk`, `lstk sam` and the snapshot commands work as usual.
`lstk start`, `lstk stop`, `lstk restart` and `lstk logs` refuse to run against an external endpoint.
Use `docker restart localstack-main` and `docker logs localstack-main` instead, or rebuild the container.

Lambda functions and other containers that LocalStack starts join the same network through `LAMBDA_DOCKER_NETWORK`.
LocalStack state is stored in the `volumePath` folder, relative to `.devcontainer/`.
For more LocalStack variables, add them to `.env` and see the [configuration reference](https://docs.localstack.cloud/aws/customization/configuration-options/).

## Using LocalStack

```bash
lstk status                 # emulator status and deployed resources
lstk aws s3 mb s3://demo    # AWS CLI against LocalStack (replaces awslocal)
aws s3 ls                   # plain aws uses the localstack profile (AWS_PROFILE=localstack)
```

For Terraform, AWS CDK or AWS SAM, add the tool's Feature and use `lstk terraform`, `lstk cdk` or `lstk sam`:

| Command | Feature |
| --- | --- |
| `lstk terraform`, `lstk tf` | `ghcr.io/devcontainers/features/terraform:1` |
| `lstk cdk` | `ghcr.io/devcontainers/features/node:1` and `ghcr.io/devcontainers-extra/features/aws-cdk:2` |
| `lstk sam` | `ghcr.io/customink/codespaces-features/sam-cli:1` |

## Migrating from 0.x

Version 1.0.0 replaces the legacy `localstack` CLI with `lstk`.
The `awslocal`, `cdklocal`, `pulumilocal`, `samlocal`, `tflocal` and `usePro` options are gone.
LocalStack now always runs the `localstack/localstack-pro` image, which needs an auth token.
See the [lstk migration guide](https://docs.localstack.cloud/aws/developer-tools/running-localstack/lstk/migration/).


---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/localstack/devcontainer-template/blob/main/src/localstack-dood/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
