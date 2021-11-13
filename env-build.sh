#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- setup
# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- cleanup

set -e
set -u

function _setup() {
    apt -y install make patch gcc g++
}

function _cleanup() {

    # remove build environment
    apt -y autoremove make patch gcc g++ || true

    # cleanup apt
    apt-get clean
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
