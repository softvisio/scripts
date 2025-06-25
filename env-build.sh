#!/usr/bin/env bash

# setup
# /usr/bin/env bash <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh) setup

# cleanup
# /usr/bin/env bash <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh) cleanup

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

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

case "${1:-}" in
    setup)
        _setup
        ;;

    cleanup)
        _cleanup
        ;;

    *)
        exit 1
        ;;
esac
