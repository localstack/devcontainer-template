# LocalStack Docker-in-Docker (localstack-dind)

Runs LocalStack inside the dev container's own Docker daemon and manages it with lstk.

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | Ubuntu or Debian version of the base image: | string | noble |
| version | LocalStack image tag (localstack/localstack-pro): | string | latest |
| logLevel | LocalStack log level (LS_LOG): | string | info |
| debug | Enable LocalStack debug mode (DEBUG): | boolean | false |
| persistence | Persist LocalStack state across restarts (PERSISTENCE): | boolean | false |
| enforceIam | Enforce IAM policies (ENFORCE_IAM): | boolean | false |
| loadPods | Cloud Pods to load at start-up, comma-separated (AUTO_LOAD_POD): | string |  |
| defaultRegion | Default AWS region for the AWS CLI and SDKs: | string | us-east-1 |
| startup | Start LocalStack with lstk when the container starts: | boolean | true |

This Template runs LocalStack inside the dev container's own Docker daemon, using the [docker-in-docker](https://github.com/devcontainers/features/tree/main/src/docker-in-docker) Feature.
[`lstk`](https://docs.localstack.cloud/aws/developer-tools/running-localstack/lstk/), the LocalStack CLI, starts and manages it.
The Template adds the [LocalStack DevContainer Feature](https://github.com/localstack/devcontainer-feature) for `lstk` and the AWS CLI Feature.

## Auth token

Set `LOCALSTACK_AUTH_TOKEN` on the host before you build the container.
The Template reads it through `${localEnv:LOCALSTACK_AUTH_TOKEN}` and never writes it into your files.
If it is not set, the container still builds. Run `lstk login` in a terminal and then `lstk start`.
See the [auth token documentation](https://docs.localstack.cloud/aws/getting-started/auth-token/).

## How it works

| File | Purpose |
| --- | --- |
| `.devcontainer/devcontainer.json` | Base image, Features, environment and lifecycle commands. |
| `.devcontainer/lstk/config.toml` | `lstk` configuration: image tag, port, mounts and LocalStack variables. `~/.config/lstk/config.toml` links to it. |
| `.devcontainer/lstk/post-create.sh` | Links the config and writes the `localstack` AWS profile with `lstk setup aws`. |
| `.devcontainer/lstk/post-start.sh` | Waits for Docker and runs `lstk start` on every container start (when `startup` is on). |

LocalStack state lives in `/var/lib/localstack` inside the emulator, backed by the `localstack-data-<id>` Docker volume mounted at `/data`.
It survives container rebuilds. Docker images are kept in the volume the docker-in-docker Feature creates.

To change LocalStack settings, edit `.devcontainer/lstk/config.toml` and run `lstk restart`.
For the available variables see the [configuration reference](https://docs.localstack.cloud/aws/customization/configuration-options/).

## Using LocalStack

```bash
lstk status                 # emulator status and deployed resources
lstk aws s3 mb s3://demo    # AWS CLI against LocalStack (replaces awslocal)
aws s3 ls                   # plain aws uses the localstack profile (AWS_PROFILE=localstack)
lstk logs --follow
lstk stop
```

`AWS_PROFILE=localstack` also points the AWS SDKs at LocalStack.
The Template does not set `AWS_ENDPOINT_URL`, because `lstk start` refuses to run when it is set.

For Terraform, AWS CDK or AWS SAM, add the tool's Feature and use `lstk terraform`, `lstk cdk` or `lstk sam`:

| Command | Feature |
| --- | --- |
| `lstk terraform`, `lstk tf` | `ghcr.io/devcontainers/features/terraform:1` |
| `lstk cdk` | `ghcr.io/devcontainers/features/node:1` and `ghcr.io/devcontainers-extra/features/aws-cdk:2` |
| `lstk sam` | `ghcr.io/customink/codespaces-features/sam-cli:1` |

## Migrating from 0.x

Version 1.0.0 replaces the legacy `localstack` CLI with `lstk`.
The `awslocal`, `cdklocal`, `pulumilocal`, `samlocal`, `tflocal`, `usePro` and `volumePath` options are gone.
LocalStack now always runs the `localstack/localstack-pro` image, which needs an auth token.
See the [lstk migration guide](https://docs.localstack.cloud/aws/developer-tools/running-localstack/lstk/migration/).


---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/localstack/devcontainer-template/blob/main/src/localstack-dind/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
