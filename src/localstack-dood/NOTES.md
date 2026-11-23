This version of the Template starts up LocalStack as a separate container in the same Docker network using the host system's Docker socket.

To control LocalStack's behaviour adjust the provided `.env` file which will be loaded both into LocalStack and the created DevContainer after rebuild.
For further customisation you can edit the provided `Dockerfile` and/or the `devcontainer.json` file.
Or add additional services by modifying the provided `docker-compose.yml` file.
For further LocalStack configuration options please consult our [official documentation](https://docs.localstack.cloud/references/configuration/).

The Template installs [lstk](https://github.com/localstack/lstk), the LocalStack CLI. Besides managing LocalStack, lstk proxies `aws`, `terraform`, `cdk`, `sam` and `az` commands to LocalStack (e.g. `lstk aws s3 ls`). The wrapped tools themselves need to be added separately, e.g. via the `ghcr.io/devcontainers/features/aws-cli` Feature.

>[!WARNING]
> In this Template version LocalStack is managed by Docker Compose, lstk only talks to it via `AWS_ENDPOINT_URL` (set in `.env`). Lifecycle commands such as `lstk start` and `lstk stop` are therefore not available.
>
> In case the LocalStack container is not running, try running `docker compose -f <DEV_CONTAINER_CONFIG_LOCATION>/docker-compose.yml up -d localstack` or rebuild the container.

#### Auth Token

An Auth Token is required to start LocalStack. Set the `LOCALSTACK_AUTH_TOKEN` environment variable on your host system, it will be automatically picked up by the Template via the `.env` file.
You can find your Auth Token in the [LocalStack Web Application](https://app.localstack.cloud/workspace/auth-token).