#!/bin/bash

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/cloud/update.sh)

DOCKER_STACK_TMP_DIR=/tmp/$DOCKER_STACK_NAME

set -e
shopt -s extglob

cd "${0%/*}"

chmod +x */docker-compose.yaml

# prepare tmp dir
rm -rf $DOCKER_STACK_TMP_DIR
mkdir -p $DOCKER_STACK_TMP_DIR

# resolve services
for name in !(*.disabled); do
    if [ -f "$name/docker-compose.yaml" ]; then

        docker stack config \
            -c $name/docker-compose.yaml \
            -c docker-compose.yaml \
            > $DOCKER_STACK_TMP_DIR/$name.docker-compose.yaml

    fi
done

# remove stack
docker stack rm --detach=false $DOCKER_STACK_NAME

# deploy stack
ls $DOCKER_STACK_TMP_DIR/*.docker-compose.yaml | xargs printf -- '-c %s\n' | xargs \
    docker stack deploy \
    --prune \
    --resolve-image=always \
    --detach=true \
    --with-registry-auth \
    $DOCKER_STACK_NAME

# remove tmp dir
rm -rf $DOCKER_STACK_TMP_DIR
