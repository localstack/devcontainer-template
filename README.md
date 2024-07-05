# DevContainer Templates
A collection of LocalStack related and managed DevContainer Templates.

>Development Container Templates are source files packaged together that encode configuration for a complete development environment.
A Template can be used in a new or existing project, and a [supporting tool](https://containers.dev/supporting) will use the configuration from the Template to build a development container.

>[!NOTE]
> This repo follows the [**proposed** DevContainer Template distribution specification](https://containers.dev/implementors/templates-distribution/).

>[!WARNING]
> This repo currently a work in progress which might introduce breaking changes without notification.

## List of templates
- LocalStack Docker-in-Docker: setup a devcontainer with LocalStack running in an internal Docker service
- LocalStack Docker-outside-of-Docker: setup a devcontainer communicating with a separate LocalStack instance running on the same Docker network

## Usage

To use either of the templates use a supported tool and choose one of them, then either add custom values to the options or keep the defaults.
Alternatively, copy the contents of the desired template's `.devcontainer` folder and customize it as necessary.

Both variation of the templates adds automativally the [official LocalStack DevContainer Feature](https://github.com/localstack/devcontainer-feature), which installs the CLI and by demand the most popular Local™ Tools.
Currently this calls for a **Debian-based** DevContainer image.

### LocalStack - Docker-in-Docker

This version of the template starts up LocalStack in an internal Docker service in the DevContainer, hence we set a volume by default for data persistence.
As a result the newly built DevContainers do not necessarily need to re-download images until this volume exists on the system.

LocalStack in this variation is controlled via the LocalStack CLI and some env variables that you can adjust or expand in the `devcontainer.json` file's `remoteEnv` block.
For further configuration options please refer our [official documentation](https://docs.localstack.cloud/references/configuration/).

#### Use LocalStack Pro

Set `usePro: true` and set on your host system the `LOCALSTACK_AUTH_TOKEN` environment variable, this will be automatically picked up by the template.

### LocalStack - Docker-outside-of-Docker

This version of the template starts up LocalStack as a separate container in the same Docker network as the current DevContainer.

To control LocalStack's behaviour adjust the provided `.env` file which will be loaded into LocalStack and the devcontainer after rebuild.
For further configuration options please refer our [official documentation](https://docs.localstack.cloud/references/configuration/).

Add additional services by modifying the provided `docker-compose.yml` file.

>[!WARNING] In this template version however the LocalStack CLI provides the `start` and `stop` options do not control the LocalStack container with them as that would result in name resolution issues with the container. In case you've made this mistake by accident, try running `docker compose -f <DEV_CONTAINER_CONFIG_LOCATION>/docker-compose.yml up -d localstack` or rebuild the container.

#### Use LocalStack Pro

Set `usePro: true` and set on your host system the `LOCALSTACK_AUTH_TOKEN` environment variable, this will be automatically picked up by the `.env` file.

## Repo and Template Structure

This repository contains a _collection_ of two Templates - `hello` and `color`. These Templates serve as simple template implementations which helps containerize the project. Similar to the [`devcontainers/templates`](https://github.com/devcontainers/templates) repo, this repository has a `src` folder.  Each Template has its own sub-folder, containing at least a `devcontainer-template.json` and `.devcontainer/devcontainer.json`. 

```
├── src
│   ├── localstack-dind
│   │   ├── devcontainer-template.json
│   │   ├── inputs.json
│   │   └──| .devcontainer
│   │      └── devcontainer.json
│   ├── localstack-dood
│   │   ├── devcontainer-template.json
│   │   └──| .devcontainer
│   │      ├── .env
│   │      ├── devcontainer.json
│   │      ├── docker-compose.yaml
│   │      └── Dockerfile
|   ├── ...
│   │   ├── devcontainer-template.json
│   │   └──| .devcontainer
│   │      └── devcontainer.json
├── test
│   ├── localstack-dind
|   |   ├── scenarios.json
│   │   └── test.sh
│   ├── localstack-dood
│   │   └── test.sh
│   └──test-utils
│      └── test-utils.sh
...
```

### Options

All available options for a Template should be declared in the `devcontainer-template.json`. The syntax for the `options` property can be found in the [devcontainer Template json properties reference](https://containers.dev/implementors/templates#devcontainer-templatejson-properties).

For example, the `color` Template provides three possible options (`red`, `gold`, `green`), where the default value is set to "red".

```jsonc
{
    // ...
    "options": {
        "favorite": {
            "type": "string",
            "description": "Choose your favorite color."
            "proposals": [
                "red",
                "gold",
                "green"
            ],
            "default": "red"
        }
    }
}
```

An [implementing tool](https://containers.dev/supporting#tools) will use the `options` property from [the documented Dev Container Template properties](https://containers.dev/implementors/templates#devcontainer-templatejson-properties) for customizing the Template. See [option resolution example](https://containers.dev/implementors/templates#option-resolution-example) for details.

## Distributing Templates

**Note**: *Allow GitHub Actions to create and approve pull requests* should be enabled in the repository's `Settings > Actions > General > Workflow permissions` for auto generation of `src/<template>/README.md` per Template (which merges any existing `src/<template>/NOTES.md`).

### Versioning

Templates are individually versioned by the `version` attribute in a Template's `devcontainer-template.json`. Templates are versioned according to the semver specification. More details can be found in [the Dev Container Template specification](https://containers.dev/implementors/templates-distribution/#versioning).

### Publishing

> NOTE: The Distribution spec can be [found here](https://containers.dev/implementors/templates-distribution/).  
>
> While any registry [implementing the OCI Distribution spec](https://github.com/opencontainers/distribution-spec) can be used, this template will leverage GHCR (GitHub Container Registry) as the backing registry.

Templates are source files packaged together that encode configuration for a complete development environment.

This repo contains a GitHub Action [workflow](.github/workflows/release.yaml) that will publish each template to GHCR.  By default, each Template will be prefixed with the `<owner/<repo>` namespace.  For example, the two Templates in this repository can be referenced by an [implementing tool](https://containers.dev/supporting#tools) with:

```
ghcr.io/devcontainers/template-starter/color:latest
ghcr.io/devcontainers/template-starter/hello:latest
```

The provided GitHub Action will also publish a third "metadata" package with just the namespace, eg: `ghcr.io/devcontainers/template-starter`. This contains information useful for tools aiding in Template discovery.

'`devcontainers/template-starter`' is known as the template collection namespace.

### Marking Template Public

For your Template to be used, it currently needs to be available publicly. By default, OCI Artifacts in GHCR are marked as `private`. 

To make them public, navigate to the Template's "package settings" page in GHCR, and set the visibility to 'public`. 

```
https://github.com/users/<owner>/packages/container/<repo>%2F<templateName>/settings
```

### Adding Templates to the Index

Next you will need to add your Templates collection to our [public index](https://containers.dev/templates) so that other community members can find them. Just follow these steps once per collection you create:

* Go to [github.com/devcontainers/devcontainers.github.io](https://github.com/devcontainers/devcontainers.github.io)
     * This is the GitHub repo backing the [containers.dev](https://containers.dev/) spec site
* Open a PR to modify the [collection-index.yml](https://github.com/devcontainers/devcontainers.github.io/blob/gh-pages/_data/collection-index.yml) file

This index is from where [supporting tools](https://containers.dev/supporting) like [VS Code Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) and [GitHub Codespaces](https://github.com/templates/codespaces) surface Templates for their Dev Container Creation Configuration UI.

### Testing Templates

This repo contains a GitHub Action [workflow](.github/workflows/test-pr.yaml) for testing the Templates. Similar to the [`devcontainers/templates`](https://github.com/devcontainers/templates) repo, this repository has a `test` folder.  Each Template has its own sub-folder, containing at least a `test.sh`.

For running the tests locally, you would need to execute the following commands -

```
    ./.github/actions/smoke-test/build.sh ${TEMPLATE-ID} 
    ./.github/actions/smoke-test/test.sh ${TEMPLATE-ID} 
```

To override the default values for example for manual testing an `inputs.json` file can be defined in the template folder. The file's structure is the following:
```json
{
    "input1": "value1",
    "input2": "value2"
...
}
```

#### Scenario Tests
Additionally the repo had been extended for scenario testing. To define scenario tests, you would need to define a `scenarios.json` file in the respective template's `test` folder. The file's structure is the following:

```json
{
	"<scenario_name>": {
        "<option_name>": "<option_value>",
        ...
        "input": "value"
	},
	...
	"my_scenario1": {
		"input1": "value1",
		"input2": "value2"
	},
	"my_scenario2": {
		"input1": "value2"
	}
}
```
By defining a scenario, you additionally need to define a similarly named shell script in the folder, ie. if the scenario key was `test_with_my_input` needs a `test_with_my_input.sh` file.

For running the tests locally, you would need to execute the following commands -

```
    ./.github/actions/scenario-test/controller.sh ${TEMPLATE-ID}
```

#### Input precedence
To test with different inputs custom values can be provided with the following precedence in a top to bottom approach (top=highest, bottom=lowest):
1. `scenario.json` (only with scenario tests)
2. `inputs.json`
3. `devcontainer-template.json`

### Updating Documentation

This repo contains a GitHub Action [workflow](.github/workflows/release.yaml) that will automatically generate documentation (ie. `README.md`) for each Template. This file will be auto-generated from the `devcontainer-template.json` and `NOTES.md`.
