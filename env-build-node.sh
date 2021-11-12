#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh | /bin/bash -s -- setup
# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh | /bin/bash -s -- cleanup

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh | /bin/bash -s -- setup-build
# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh | /bin/bash -s -- cleanup-build

set -e
set -u

function _setup() {
    local PACKAGES=""

    PACKAGES="$PACKAGES git"

    apt -y install $PACKAGES
}

function _setup_build() {

    # setup build env
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- setup

    local PACKAGES=""

    PACKAGES="$PACKAGES git python3 make g++"

    apt -y install $PACKAGES
}

function _cleanup() {
    local PACKAGES=""

    PACKAGES="$PACKAGES git"

    apt -y autoremove $PACKAGES

    # cleanup apt
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    # clean npm cache
    rm -rf ~/.npm-cache
}

function _cleanup_build() {
    local PACKAGES=""

    PACKAGES="$PACKAGES git python3 make g++"

    apt -y autoremove $PACKAGES

    # cleanup build env
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- cleanup

    # cleanup apt
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    # clean npm cache
    rm -rf ~/.npm-cache
}

case "$1" in
    setup)
        _setup
        ;;

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
