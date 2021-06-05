#!/bin/bash

# curl -fsSLO https://bitbucket.org/softvisio/scripts/raw/main/mariadb.sh && chmod +x mariadb.sh
# MYSQL_ROOT_PASSWORD=1 ./mariadb.sh

set -e

SCRIPT_DIR="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

export TAG=latest
export NAME=mariadb
export DOCKERHUB_NAMESPACE=
export SERVICE=1

# docker container restart policy - https://docs.docker.com/config/containers/start-containers-automatically/
export RESTART=always

export KILL_TIMEOUT=10

if [[ ! -z $MYSQL_ROOT_PASSWORD ]]; then
    PASSWORD="MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
else
    PASSWORD="MYSQL_RANDOM_ROOT_PASSWORD=1"

    echo "to see generated root password run: docker logs mariadb 2>&1 | grep \"GENERATED ROOT PASSWORD\""
fi

export DOCKER_CONTAINER_ARGS="
    -e $PASSWORD \
    -v mariadb:/var/lib/mysql \
    -p 3306:3306/tcp \
"

curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/docker.sh | /bin/bash -s -- "$@"

docker logs mariadb
