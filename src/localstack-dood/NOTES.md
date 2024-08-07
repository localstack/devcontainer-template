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