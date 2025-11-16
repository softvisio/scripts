#!/usr/bin/env bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh")
# bash <(echo "$script")

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

# install common packages
npm install --global \
    corepack \
    neovim

# link packages globally
pushd /var/local/softvisio-node/cli
npm link
popd

pushd /var/local/softvisio-node/core
npm link
popd

pushd /var/local/zdm/utils
npm link
popd

# clear npm cache
npm cache clean --force
