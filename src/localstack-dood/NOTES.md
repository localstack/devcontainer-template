This version of the template starts up LocalStack as a separate container in the same Docker network as the current DevContainer.

To control LocalStack's behaviour adjust the provided `.env` file which will be loaded into LocalStack and the devcontainer after rebuild.
For further configuration options please refer our [official documentation](https://docs.localstack.cloud/references/configuration/).

Add additional services by modifying the provided `docker-compose.yml` file.

The template adds automativally the [official LocalStack DevContainer Feature](https://github.com/localstack/devcontainer-feature), which installs the CLI and by demand the most popular Local™ Tools.
Currently this calls for a **Debian-based** DevContainer image.

>[!WARNING] In this template version however the LocalStack CLI provides the `start` and `stop` options do not control the LocalStack container with them as that would result in name resolution issues with the container. In case you've made this mistake by accident, try running `docker compose -f <DEV_CONTAINER_CONFIG_LOCATION>/docker-compose.yml up -d localstack` or rebuild the container.

#### Use LocalStack Pro

Set `usePro: true` and set on your host system the `LOCALSTACK_AUTH_TOKEN` environment variable, this will be automatically picked up by the `.env` file.