#!/usr/bin/env bash

# setup
# /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh) setup

# cleanup
# /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh) cleanup

set -e

function _setup() {
    apt-get update
    apt-get install -y make patch gcc g++
}

function _cleanup() {

    # remove build environment
    apt-get autoremove -y make patch gcc g++ || true

    # cleanup apt
    apt-get clean
    rm -rf /var/lib/apt/lists/*
}

case "$1" in
    setup)
        _setup
        ;;

    cleanup)
        _cleanup
        ;;

    *)
        return 1
        ;;
esac
