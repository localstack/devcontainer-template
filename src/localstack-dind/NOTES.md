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