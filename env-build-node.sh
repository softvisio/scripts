#!/usr/bin/env bash

# cleanup
# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh) cleanup

# setup build environment
# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh) setup-build

# cleanup build environment
# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh) cleanup-build

set -e

function _setup_build() {

    # setup build env
    /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh) setup

    local PACKAGES=""

    PACKAGES="$PACKAGES git python3 make g++"

    apt-get install -y $PACKAGES
}

function _cleanup() {

    # cleanup apt
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    # clean npm cache
    # npm cache clear --force
    rm -rf ~/.npm-cache
}

function _cleanup_build() {
    local PACKAGES=""

    PACKAGES="$PACKAGES git python3 make g++"

    apt-get autoremove -y $PACKAGES || true

    # cleanup build env
    /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh) cleanup

    # cleanup apt
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    # clean npm cache
    # npm cache clear --force
    rm -rf ~/.npm-cache
}

case "$1" in
    setup-build)
        _setup_build

        ;;
    cleanup)
        _cleanup

        ;;
    cleanup-build)
        _cleanup_build

        ;;
    *)
        return 1

        ;;
esac
