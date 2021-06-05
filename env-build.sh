#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- setup
# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- cleanup

set -e
set -u

function _setup() {
    dnf -y install make patch gcc gcc-c++
}

function _cleanup() {

    # remove build environment
    dnf -y autoremove gcc gcc-c++

    # cleanup dnf
    dnf clean all

    # remove dnf cache
    rm -rf /var/cache/dnf

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
