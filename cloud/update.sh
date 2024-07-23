#!/bin/bash

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/cloud/update.sh)

STACK_TMP_DIR=/tmp/$STACK_NAME

set -e
shopt -s extglob

cd "${0%/*}"

chmod +x **/docker-compose.yaml

# create network if not exists
[ -z $(docker network ls -q --filter name=main) ] && docker network create --driver overlay --attachable main

# prepare tmp dir
rm -rf $STACK_TMP_DIR
mkdir -p $STACK_TMP_DIR

# resolve services
for name in !(*.disabled); do
    if [ -f "$name/docker-compose.yaml" ]; then
        docker stack config \
            -c $name/docker-compose.yaml \
            > $STACK_TMP_DIR/$name.docker-compose.yaml
    fi
done

# remove stack
docker stack rm --detach=false $STACK_NAME

# deploy stack
ls $STACK_TMP_DIR/*.docker-compose.yaml | xargs printf -- '-c %s\n' | xargs \
    docker stack deploy \
    --prune \
    --resolve-image=always \
    --detach=false \
    --with-registry-auth \
    $STACK_NAME

# remove tmp dir
rm -rf $STACK_TMP_DIR
