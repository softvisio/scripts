#!/bin/bash

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/cloud/update.sh)

set -e
shopt -s extglob

cd "${0%/*}"

chmod +x **/docker-compose.yaml

# create network if not exists
[ -z $(docker network ls -q --filter name=main) ] && docker network create --driver overlay --attachable main

# remove services
for name in *; do
    if [ -f "$name/docker-compose.yaml" ]; then
        docker stack rm ${name%%.*}
    fi
done

# create services
for name in !(*.disabled); do
    if [ -f "$name/docker-compose.yaml" ]; then
        $name/docker-compose.yaml
    fi
done
