#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh | /bin/bash

set -e

# if [[ ! -x "$(command -v node)" && -x "$(command -v n)" ]]; then
#     n latest
# fi

# make global modules loadable
rm -rf ~/.node_modules
ln -s ~/.npm/lib/node_modules ~/.node_modules

# update node_modules
npm install --global npm
# npm update --global --force --unsafe

# install common modules
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
    npm install --global \
    /var/local/@softvisio/core \
    /var/local/@softvisio/cli \
    /var/local/etc/psqls \
    cordova \
    neovim
