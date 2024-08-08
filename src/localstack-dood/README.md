
# LocalStack Docker-outside-of-Docker (localstack-dood)

A template to manage LocalStack in DooD

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
| networkName | - | string | ls |
| networkCidr | - | string | 10.0.2.0/24 |
| ipAddress | - | string | 10.0.2.20 |
| host | - | string | localhost.localstack.cloud:4566 |
| debug | - | boolean | false |
| persistence | - | boolean | false |
| usePro | - | boolean | false |
| version | - | string | latest |
| loadPods | - | string |   |
| volumePath | - | string | ./.volume |
| enforceIam | - | boolean | false |
| defaultRegion | - | string | us-east-1 |

This version of the Template starts up LocalStack as a separate container in the same Docker network using the host system's Docker socket.

To control LocalStack's behaviour adjust the provided `.env` file which will be loaded both into LocalStack and the created DevContainer after rebuild.
For further customisation you can edit the provided `Dockerfile` and/or the `devcontainer.json` file.
Or add additional services by modifying the provided `docker-compose.yml` file.
For further LocalStack configuration options please consult our [official documentation](https://docs.localstack.cloud/references/configuration/).

The Template adds automatically the [official LocalStack DevContainer Feature](https://github.com/localstack/devcontainer-feature), which installs the CLI and by demand the most popular *Local Tools™*.
Currently this calls for a **Debian-based** DevContainer image.

>[!WARNING]
> In this Template version however the LocalStack CLI provides the `start` and `stop` options do not control the LocalStack container with them as that would result in name resolution issues with the container.
>
> In case you've made this mistake by accident, try running `docker compose -f <DEV_CONTAINER_CONFIG_LOCATION>/docker-compose.yml up -d localstack` or rebuild the container.

#### Use LocalStack Pro

Set `usePro: true` and set on your host system the `LOCALSTACK_AUTH_TOKEN` or the `LOCALSTACK_API_KEY` environment variable, this will be automatically picked up by the `.env` file.

---

_Note: This file was auto-generated from the [devcontainer-template.json](https://github.com/localstack/devcontainer-template/blob/main/src/localstack-dood/devcontainer-template.json).  Add additional notes to a `NOTES.md`._
