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

    dnf -y install $PACKAGES
}

function _setup_build() {

    # setup build env
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- setup

    local PACKAGES=""

    PACKAGES="$PACKAGES git python3 make gcc-c++"

    dnf -y install $PACKAGES
}

function _cleanup() {
    local PACKAGES=""

    PACKAGES="$PACKAGES git"

    dnf -y autoremove $PACKAGES

    dnf clean all

    # remove dnf cache
    rm -rf /var/cache/dnf
}

function _cleanup_build() {
    local PACKAGES=""

    PACKAGES="$PACKAGES git python3 make gcc-c++"

    dnf -y autoremove $PACKAGES

    # cleanup build env
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- cleanup

    dnf clean all
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
