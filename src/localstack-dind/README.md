
# LocalStack Docker-in-Docker (localstack-dind)

A template to manage LocalStack in DinD via CLI

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | Debian version (use bullseye or jammy on local arm64/Apple Silicon): | string | jammy |
| logLevel | Set LocalStack log level: | string | info |
| debug | Enable LocalStack debugging: | boolean | false |
| persistence | Enable persistence in LocalStack: | boolean | false |
| version | LocalStack image version: | string | latest |
| loadPods | Load Cloud Pods at start-up (comma-separated list): | string |   |
| volumePath | LocalStack volume location on the host (currently only local (bind) mounts recommended): | string | ./.volume |
| enforceIam | Enforce IAM: | boolean | false |
| defaultRegion | Default AWS region: | string | us-east-1 |
| startup | Start up LocalStack: | boolean | true |

This version of the Template starts up LocalStack in an internal Docker service in the DevContainer, hence we set a volume by default for data persistence.
As a result the newly built DevContainers do not necessarily need to re-download images as long this volume exists on the system.  
Additionally the DevContainer bind mounts a folder from the host system as `/data`, which will be used to store LocalStack data.

The Template installs [lstk](https://github.com/localstack/lstk), the LocalStack CLI. Besides managing LocalStack, lstk proxies `aws`, `terraform`, `cdk`, `sam` and `az` commands to LocalStack (e.g. `lstk aws s3 ls`). The wrapped tools themselves need to be added separately, e.g. via the `ghcr.io/devcontainers/features/aws-cli` Feature.

LocalStack in this variation is started with `lstk start` after the DevContainer is created and is controlled with lstk (`lstk status`, `lstk stop`, `lstk logs`, ...).
The image version and the LocalStack configuration live in `.devcontainer/lstk.toml`, which is linked as the lstk config (`~/.config/lstk/config.toml`); add further LocalStack variables to its `[env.devcontainer]` section.
For further LocalStack configuration options please consult our [official documentation](https://docs.localstack.cloud/references/configuration/).

## Auth Token

An Auth Token is required to start LocalStack. Set the `LOCALSTACK_AUTH_TOKEN` environment variable on your host system, it will be automatically picked up by the Template.
You can find your Auth Token in the [LocalStack Web Application](https://app.localstack.cloud/workspace/auth-token).

---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/localstack/devcontainer-template/blob/main/src/localstack-dind/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
