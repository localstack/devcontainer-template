# DevContainer Templates
A collection of LocalStack related and managed DevContainer Templates.

>Development Container Templates are source files packaged together that encode configuration for a complete development environment.
A Template can be used in a new or existing project, and a [supporting tool](https://containers.dev/supporting) will use the configuration from the Template to build a development container.

>[!NOTE]
> This repo follows the [**proposed** DevContainer Template distribution specification](https://containers.dev/implementors/templates-distribution/).

>[!WARNING]
> This repo currently a work in progress which might introduce breaking changes without notification.

## List of Templates
- LocalStack Docker-in-Docker (`localstack-dind`): runs LocalStack inside the dev container's own Docker daemon and manages it with `lstk`.
- LocalStack Docker-outside-of-Docker (`localstack-dood`): runs LocalStack as a Docker Compose service next to the dev container, on the host's Docker daemon.

## Usage

Pick one of the Templates in a [supporting tool](https://containers.dev/supporting), such as VS Code or the Dev Container CLI, and keep the defaults or adjust the options.
You can also copy the Template's `.devcontainer` folder into your project and edit it.

Both Templates add the [LocalStack DevContainer Feature](https://github.com/localstack/devcontainer-feature), which installs [`lstk`](https://docs.localstack.cloud/aws/developer-tools/running-localstack/lstk/), the LocalStack CLI, and the AWS CLI Feature.
`lstk` replaces the legacy `localstack` CLI and the `awslocal`, `tflocal`, `cdklocal` and `samlocal` wrappers.
The Templates use Ubuntu or Debian based images.

Both Templates need a LocalStack [auth token](https://docs.localstack.cloud/aws/getting-started/auth-token/).
Set `LOCALSTACK_AUTH_TOKEN` on the host before you build the container. It is read from the host environment and never written into the Template files.

### LocalStack - Docker-in-Docker

LocalStack runs in the dev container's own Docker daemon. `lstk start` runs on every container start.
The `lstk` configuration lives in `.devcontainer/lstk/config.toml`. LocalStack state is kept in a Docker volume and survives rebuilds.
See the [Template README](src/localstack-dind/README.md).

### LocalStack - Docker-outside-of-Docker

LocalStack runs as the `localstack` service in `.devcontainer/docker-compose.yml`, on the host's Docker daemon.
`lstk` talks to it through `LSTK_ENDPOINT_URL`. Docker Compose, not `lstk`, starts and stops the LocalStack container.
LocalStack's DNS server resolves `localhost.localstack.cloud` inside the dev container, and Lambda containers join the same network.
See the [Template README](src/localstack-dood/README.md).

## Repo and Template Structure

This repository contains a _collection_ of two Templates - `localstack-dind` and `localstack-dood`. Similar to the [`devcontainers/templates`](https://github.com/devcontainers/templates) repo, this repository has a `src` folder.  Each Template has its own sub-folder, containing at least a `devcontainer-template.json` and `.devcontainer/devcontainer.json`. 

```
├── src
│   ├── localstack-dind
│   │   ├── devcontainer-template.json
│   │   ├── NOTES.md
│   │   └──| .devcontainer
│   │      ├── devcontainer.json
│   │      └──| lstk
│   │         ├── config.toml
│   │         ├── post-create.sh
│   │         └── post-start.sh
│   ├── localstack-dood
│   │   ├── devcontainer-template.json
│   │   ├── NOTES.md
│   │   └──| .devcontainer
│   │      ├── .env
│   │      ├── devcontainer.json
│   │      ├── docker-compose.yml
│   │      ├── Dockerfile
│   │      └──| lstk
│   │         └── post-start.sh
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

For example, the `localstack-dind` Template offers four image variants, with `noble` as the default.

```jsonc
{
    // ...
    "options": {
        "imageVariant": {
            "type": "string",
            "description": "Ubuntu or Debian version of the base image:",
            "proposals": ["noble", "jammy", "resolute", "bookworm"],
            "default": "noble"
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
    export LOCALSTACK_AUTH_TOKEN=<your token>
    ./.github/actions/smoke-test/build.sh ${TEMPLATE-ID} 
    ./.github/actions/smoke-test/test.sh ${TEMPLATE-ID} 
```

The scripts use GNU `sed`. To test against a local checkout of the [Feature](https://github.com/localstack/devcontainer-feature) instead of the published one, set `LOCAL_FEATURE_DIR`, for example `LOCAL_FEATURE_DIR=../devcontainer-feature/src/localstack-cli`.

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
