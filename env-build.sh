#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- setup
# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- cleanup

set -e
set -u

function _setup() {
    apt update
    apt install -y make patch gcc g++
}

function _cleanup() {

    # remove build environment
    apt autoremove -y make patch gcc g++ || true

    # cleanup apt
    apt clean
    rm -rf /var/lib/apt/lists/*

    # remove cpanm temp dir
    rm -rf /tmp/.cpanm
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
