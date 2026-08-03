#!/usr/bin/env bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh")
# bash <(echo "$script")

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

# install common packages
npm install --global \
    npm \
    corepack \
    neovim

# update global packages
npm update --global --dangerously-allow-all-scripts --force

# link packages globally
pushd /var/local/corejslib/cli
npm link --dangerously-allow-all-scripts --force
popd

pushd /var/local/corejslib/core
npm link --dangerously-allow-all-scripts --force
popd

pushd /var/local/zdm/toolset
npm link --dangerously-allow-all-scripts --force
popd

# clear npm cache
npm cache clean --force
