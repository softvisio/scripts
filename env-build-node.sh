#!/usr/bin/env bash

# script=$(curl -fsSL "https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh")
#
# cleanup
# bash <(echo "$script") cleanup
#
# setup build environment
# bash <(echo "$script") setup-build
#
# cleanup build environment
# bash <(echo "$script") cleanup-build

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

function _setup_build() {

    # setup build env
    local script
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh")
    bash <(echo "$script") setup

    local packages=""

    packages="$packages git python3 make g++"

    apt-get install -y $packages
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
    local packages=""

    packages="$packages git python3 make g++"

    apt-get autoremove -y $packages || true

    # cleanup build env
    local script
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh")
    bash <(echo "$script") cleanup

    # cleanup apt
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    # clean npm cache
    # npm cache clear --force
    rm -rf ~/.npm-cache
}

case "${1:-}" in
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
        exit 1

        ;;
esac
