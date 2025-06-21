#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh)

set -e

# if [[ ! -x "$(command -v node)" && -x "$(command -v n)" ]]; then
#     n lts
# fi

# make global modules loadable
rm -rf ~/.node_modules
ln -s ~/.npm/lib/node_modules ~/.node_modules

# update node_modules
# npm install --global npm
# npm update --global --force --unsafe

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

# install common packages
npm install --global \
    neovim

# clear npm cache
npm cache clean --force
