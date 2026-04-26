#!/usr/bin/env bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh")
# bash <(echo "$script")

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

# install common packages
npm install --global \
    corepack \
    neovim

# link packages globally
pushd /var/local/softvisio/cli
npm link
popd

pushd /var/local/corejslib/core
npm link
popd

pushd /var/local/softvisio/utils
npm link
popd

# clear npm cache
npm cache clean --force
