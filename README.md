# DevContainer Templates
A collection of LocalStack related and managed DevContainer Templates.

>Development Container Templates are source files packaged together that encode configuration for a complete development environment.
A Template can be used in a new or existing project, and a [supporting tool](https://containers.dev/supporting) will use the configuration from the Template to build a development container.

>[!NOTE]
> This repo follows the [**proposed** DevContainer Template distribution specification](https://containers.dev/implementors/templates-distribution/).

>[!WARNING]
> This repo currently a work in progress which might introduce breaking changes without notification.

## List of Templates
- LocalStack Docker-in-Docker: setup a devcontainer with LocalStack running in an internal Docker service
- LocalStack Docker-outside-of-Docker: setup a devcontainer communicating with a separate LocalStack instance running on the same Docker network

## Usage

To use either of the Templates use a supported tool and choose one of them, then either add custom values to the options or keep the defaults.
Alternatively, copy the contents of the desired Template's `.devcontainer` folder and customize it as necessary.

Both Templates install [lstk](https://github.com/localstack/lstk), the LocalStack CLI. Besides managing LocalStack, lstk proxies `aws`, `terraform`, `cdk`, `sam` and `az` commands to LocalStack (e.g. `lstk aws s3 ls`). The wrapped tools themselves need to be added separately, e.g. via the `ghcr.io/devcontainers/features/aws-cli` Feature.

### LocalStack - Docker-in-Docker

This version of the Template starts up LocalStack in an internal Docker service in the DevContainer, hence we set a volume by default for data persistence.
As a result the newly built DevContainers do not necessarily need to re-download images as long this volume exists on the system.  
Additionally the DevContainer bind mounts a folder from the host system as `/data`, which will be used to store LocalStack data.

LocalStack in this variation is started with `lstk start` after the DevContainer is created and is controlled with lstk (`lstk status`, `lstk stop`, `lstk logs`, ...).
The image version and the LocalStack configuration live in `.devcontainer/lstk.toml`, which is linked as the lstk config (`~/.config/lstk/config.toml`); add further LocalStack variables to its `[env.devcontainer]` section.
For further LocalStack configuration options please consult our [official documentation](https://docs.localstack.cloud/references/configuration/).

#### Auth Token

An Auth Token is required to start LocalStack. Set the `LOCALSTACK_AUTH_TOKEN` environment variable on your host system, it will be automatically picked up by the Template.
You can find your Auth Token in the [LocalStack Web Application](https://app.localstack.cloud/workspace/auth-token).

### LocalStack - Docker-outside-of-Docker

This version of the Template starts up LocalStack as a separate container in the same Docker network using the host system's Docker socket.

To control LocalStack's behaviour adjust the provided `.env` file which will be loaded both into LocalStack and the created DevContainer after rebuild.
For further customisation you can edit the provided `Dockerfile` and/or the `devcontainer.json` file.
Or add additional services by modifying the provided `docker-compose.yml` file.
For further LocalStack configuration options please consult our [official documentation](https://docs.localstack.cloud/references/configuration/).

>[!WARNING]
> In this Template version LocalStack is managed by Docker Compose, lstk only talks to it via `AWS_ENDPOINT_URL` (set in `.env`). Lifecycle commands such as `lstk start` and `lstk stop` are therefore not available.
>
> In case the LocalStack container is not running, try running `docker compose -f <DEV_CONTAINER_CONFIG_LOCATION>/docker-compose.yml up -d localstack` or rebuild the container.

#### Auth Token

An Auth Token is required to start LocalStack. Set the `LOCALSTACK_AUTH_TOKEN` environment variable on your host system, it will be automatically picked up by the Template via the `.env` file.
You can find your Auth Token in the [LocalStack Web Application](https://app.localstack.cloud/workspace/auth-token).

## Repo and Template Structure

This repository contains a _collection_ of two Templates - `localstack-dind` and `localstack-dood`. Similar to the [`devcontainers/templates`](https://github.com/devcontainers/templates) repo, this repository has a `src` folder.  Each Template has its own sub-folder, containing at least a `devcontainer-template.json` and `.devcontainer/devcontainer.json`. 

```
├── src
│   ├── localstack-dind
│   │   ├── devcontainer-template.json
│   │   ├── inputs.json
│   │   └──| .devcontainer
│   │      ├── devcontainer.json
│   │      ├── install-lstk.sh
│   │      └── lstk.toml
│   ├── localstack-dood
│   │   ├── devcontainer-template.json
│   │   └──| .devcontainer
│   │      ├── .env
│   │      ├── devcontainer.json
│   │      ├── docker-compose.yaml
│   │      ├── Dockerfile
│   │      └── install-lstk.sh
|   ├── ...
│   │   ├── devcontainer-template.json
│   │   └──| .devcontainer
│   │      └── devcontainer.json
├── test
│   ├── localstack-dind
|   |   ├── scenarios.json
|   |   ├── ...
│   │   └── test.sh
│   ├── localstack-dood
|   |   ├── scenarios.json
|   |   ├── ...
│   │   └── test.sh
│   └──test-utils
│      └── test-utils.sh
...
```

### Options

All available options for a Template should be declared in the `devcontainer-template.json`. The syntax for the `options` property can be found in the [devcontainer Template json properties reference](https://containers.dev/implementors/templates#devcontainer-templatejson-properties).

For example, the `localstack-dind` Template provides four possible options (`jammy`, `focal`, `bookworm`, `bullseye`), where the default value is set to `jammy`.

```jsonc
{
    // ...
    "options": {
        "imageVariant": {
            "type": "string",
            "description": "Debian version (use bullseye or jammy on local arm64/Apple Silicon):",
            "proposals": [
                "jammy",
                "focal",
                "bullseye",
                "bookworm"
            ],
            "default": "jammy"
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

>[!NOTE]
> NOTE: The Distribution spec can be [found here](https://containers.dev/implementors/templates-distribution/).  
>
> While any registry [implementing the OCI Distribution spec](https://github.com/opencontainers/distribution-spec) can be used, this template will leverage GHCR (GitHub Container Registry) as the backing registry.

Templates are source files packaged together that encode configuration for a complete development environment.

This repo contains a GitHub Action [workflow](.github/workflows/release.yaml) that will publish each template to GHCR.  By default, each Template will be prefixed with the `<owner>/<repo>` namespace.  For example, the two Templates in this repository can be referenced by an [implementing tool](https://containers.dev/supporting#tools) with:

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

To override the default values for example for manual testing an `inputs.json` file can be defined in the Template's folder. The file's structure is the following:
```json
{
    "input1": "value1",
    "input2": "value2"
...
}
```

#### Scenario Tests
Additionally the repo had been extended for scenario testing. To define scenario tests, you would need to define a `scenarios.json` file in the respective Template's `test` folder. The file's structure is the following:

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

In case of scenarios you can add any other valid DevContainer config options like `features` or `customizations`, that you'd use normally, these options will be merged into the resulting `devcontainers.json` file.

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
