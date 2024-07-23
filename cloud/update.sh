#!/bin/bash

# /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/cloud/update.sh) $STACK_NAME

STACK_NAME=$1

set -e
shopt -s extglob

cd "${0%/*}"

chmod +x **/docker-compose.yaml

# create network if not exists
[ -z $(docker network ls -q --filter name=main) ] && docker network create --driver overlay --attachable main

# remove stack
docker stack rm $STACK_NAME

# remove resolved compose files
rm -rf **/docker-compose.resolved.yaml

# resolve services
for name in !(*.disabled); do
    if [ -f "$name/docker-compose.yaml" ]; then
        docker stack config \
            -c $name/docker-compose.yaml \
            > $name/docker-compose.resolved.yaml
    fi
done

# deploy stack
ls **/docker-compose.resolved.yaml | xargs printf -- '-c %s\n' | xargs \
    docker stack deploy \
    --prune \
    --resolve-image=always \
    --detach \
    --with-registry-auth \
    $STACK_NAME

# remove resolved compose files
rm -rf **/docker-compose.resolved.yaml
