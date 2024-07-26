This version of the template starts up LocalStack in an internal Docker service in the DevContainer, hence we set a volume by default for data persistence.
As a result the newly built DevContainers do not necessarily need to re-download images until this volume exists on the system.  
Additionally the DevContainer bind mounts a folder from the host system as `/data`, which will be used to store LocalStack data (`LOCALSTACK_VOLUME_DIR`).

The template adds automativally the [official LocalStack DevContainer Feature](https://github.com/localstack/devcontainer-feature), which installs the CLI and by demand the most popular Local™ Tools.
Currently this calls for a **Debian-based** DevContainer image.

LocalStack in this variation is controlled via the LocalStack CLI and some env variables that you can adjust or expand in the `devcontainer.json` file's `remoteEnv` block.
For further LocalStack configuration options please consult our [official documentation](https://docs.localstack.cloud/references/configuration/).

## Use LocalStack Pro

Set `usePro: true` and set on your host system the `LOCALSTACK_AUTH_TOKEN` or the `LOCALSTACK_API_KEY` environment variable, this will be automatically picked up by the template.