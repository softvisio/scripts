#!/usr/bin/env bash

# script=$(curl -fsSL "https://raw.githubusercontent.com/softvisio/scripts/main/docker-stack.sh")
# bash <(echo "$script")

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

shopt -s extglob

if [[ -z $SOURCE ]]; then
    echo "\$SOURCE is required" >&2

    exit 1
fi

if [[ -z $DOCKER_STACK_NAME ]]; then
    echo "\$DOCKER_STACK_NAME is required" >&2

    exit 1
fi

if [[ -z $DOCKER_STACK_NETWORK_NAME ]]; then
    DOCKER_STACK_NETWORK_NAME=${DOCKER_STACK_NAME}_network
fi

export DOCKER_STACK_NAME=$DOCKER_STACK_NAME
export DOCKER_STACK_NETWORK_NAME=$DOCKER_STACK_NETWORK_NAME

# create tmp dirs
source_tmp_dir=$(mktemp -d)
export DOCKER_STACK_TMP_DIR=$(mktemp -d)

function _clone_source() {
    if [[ ! -f "package.json" ]]; then
        cd $source_tmp_dir

        git clone --quiet --depth=1 --single-branch ssh://git@github.com/$SOURCE .

        # unlock
        if [[ -f "./unlock.sh" ]]; then
            ./unlock.sh || true
        fi

        git crypt unlock
    fi
}

function _create_external_network() {

    # create external network if not exists
    if [[ ! -z $DOCKER_STACK_EXTERNAL_NETWORK ]]; then
        if [[ -z $(docker network ls -q --filter name=$DOCKER_STACK_NETWORK_NAME) ]]; then
            echo Creating stack network ${DOCKER_STACK_NETWORK_NAME}: $(docker network create $DOCKER_STACK_EXTERNAL_NETWORK $DOCKER_STACK_NETWORK_NAME)
        fi
    fi
}

function _cleanup() {
    rm -rf $DOCKER_STACK_TMP_DIR
    rm -rf $source_tmp_dir
}

if _clone_source; then

    # resolve services
    for name in *; do
        if [ -f "$name/compose.yaml" ]; then

            docker stack config \
                -c "$name/compose.yaml" \
                -c compose.yaml \
                > $DOCKER_STACK_TMP_DIR/${name}.compose.yaml

        fi
    done

    # remove stack
    docker stack rm --detach=false $DOCKER_STACK_NAME

    # create external network if not exists
    _create_external_network

    # deploy stack
    ls $DOCKER_STACK_TMP_DIR/*.compose.yaml | xargs printf -- '-c %s\n' | xargs \
        docker stack deploy \
        --prune \
        --resolve-image=always \
        --detach=true \
        --with-registry-auth \
        $DOCKER_STACK_NAME

fi

_cleanup
