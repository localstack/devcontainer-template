#!/usr/bin/env bash
# Installs lstk, the LocalStack CLI: https://github.com/localstack/lstk
# Usage: install-lstk.sh [config.toml]
#   config.toml  optional lstk config, linked to ~/.config/lstk/config.toml so every lstk command uses it
# Set LSTK_VERSION (e.g. 1.5.0) to pin a release, defaults to the latest one.
set -euo pipefail

CONFIG_FILE="${1:-}"
VERSION="${LSTK_VERSION:-latest}"
if [ "$VERSION" = "latest" ]; then
    VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/localstack/lstk/releases/latest)
    VERSION="${VERSION##*/}"
fi
VERSION="${VERSION#v}"

case "$(uname -m)" in
    x86_64|amd64) ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "https://github.com/localstack/lstk/releases/download/v${VERSION}/lstk_${VERSION}_linux_${ARCH}.tar.gz" \
    | tar -xz -C "$TMP_DIR"

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"
# Keep the whole archive together: lstk finds its bundled extensions next to the
# symlink-resolved binary.
$SUDO rm -rf /usr/local/lib/lstk
$SUDO mkdir -p /usr/local/lib/lstk
$SUDO cp -R "$TMP_DIR"/. /usr/local/lib/lstk/
$SUDO ln -sf /usr/local/lib/lstk/lstk /usr/local/bin/lstk

if [ -n "$CONFIG_FILE" ]; then
    mkdir -p "$HOME/.config/lstk"
    ln -sf "$(realpath "$CONFIG_FILE")" "$HOME/.config/lstk/config.toml"
fi

lstk --version
