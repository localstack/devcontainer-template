
# LocalStack Docker-in-Docker (localstack-dind)

A template to manage LocalStack in DinD via CLI

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| imageVariant | Debian version (use bullseye or jammy on local arm64/Apple Silicon): | string | jammy |
| awslocal | Install LocalStack wrapper for AWS CLI: | boolean | false |
| cdklocal | Install LocalStack wrapper for CDK: | boolean | false |
| pulumilocal | Install LocalStack wrapper for Pulumi: | boolean | false |
| samlocal | Install LocalStack wrapper for AWS SAM CLI: | boolean | false |
| tflocal | Install LocalStack wrapper for Terraform: | boolean | false |
| logLevel | Set LocalStack log level: | string | info |
| debug | - | boolean | false |
| persistence | - | boolean | false |
| usePro | - | boolean | false |
| version | - | string | latest |
| loadPods | - | string |   |
| volumePath | - | string | ./.volume |
| enforceIam | - | boolean | false |
| defaultRegion | - | string | us-east-1 |
| startup | Start up LocalStack: | boolean | true |

This version of the Template starts up LocalStack in an internal Docker service in the DevContainer, hence we set a volume by default for data persistence.
As a result the newly built DevContainers do not necessarily need to re-download images as long this volume exists on the system.  
Additionally the DevContainer bind mounts a folder from the host system as `/data`, which will be used to store LocalStack data (`LOCALSTACK_VOLUME_DIR`).

The Template adds automatically the [official LocalStack DevContainer Feature](https://github.com/localstack/devcontainer-feature), which installs the CLI and by demand the most popular *Local Tools™*.
Currently this calls for a **Debian-based** DevContainer image.

LocalStack in this variation is controlled via the LocalStack CLI and some env variables that you can adjust or expand in the `devcontainer.json` file's `remoteEnv` block.
For further LocalStack configuration options please consult our [official documentation](https://docs.localstack.cloud/references/configuration/).

## Use LocalStack Pro

Set `usePro: true` and set on your host system the `LOCALSTACK_AUTH_TOKEN` or the `LOCALSTACK_API_KEY` environment variable, this will be automatically picked up by the Template.

---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/localstack/devcontainer-template/blob/main/src/localstack-dind/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
