#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/docker-stack.sh)

set -e
shopt -s extglob

if [[ -z $SOURCE ]]; then
    echo \$SOURCE is required

    exit 1
fi

if [[ -z $DOCKER_STACK_NAME ]]; then
    echo \$DOCKER_STACK_NAME is required

    exit 1
fi

if [[ -z $DOCKER_STACK_NETWORK_NAME ]]; then
    DOCKER_STACK_NETWORK_NAME=${DOCKER_STACK_NAME}_network
fi

export DOCKER_STACK_NAME=$DOCKER_STACK_NAME
export DOCKER_STACK_NETWORK_NAME=$DOCKER_STACK_NETWORK_NAME

# create tmp dirs
SOURCE_TMP_DIR=$(mktemp -d)
export DOCKER_STACK_TMP_DIR=$(mktemp -d)

function _clone_source() {
    if [[ ! -f "package.json" ]]; then
        cd $SOURCE_TMP_DIR

        git clone --depth=1 --single-branch ssh://git@github.com/$SOURCE .

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
    rm -rf $SOURCE_TMP_DIR
}

if (_clone_source); then

    # resolve services
    for name in *; do
        if [ -f "$name/compose.yaml" ]; then

            docker stack config \
                -c $name/compose.yaml \
                -c compose.yaml \
                > $DOCKER_STACK_TMP_DIR/$name.compose.yaml

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
