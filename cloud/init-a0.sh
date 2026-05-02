#!/usr/bin/env bash

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

apt-get install -y \
    mc \
    htop

apt-get install -y \
    git \
    git-lfs \
    git-crypt

apt-get install -y \
    postgresql-client-18

# add gpg deployment key
script=$(curl -fsS "https://raw.githubusercontent.com/zdm/dotfiles-public/main/gpg/restore-deployment@softvisio.net.sh") && bash <(echo "$script")

# install deployment dotfiles
update-dotfiles deployment

# init docker swarm
docker swarm init

# set docker nodes labels
docker node update --label-add postgresql=primary $(docker node inspect self --format "{{ .ID }}")
docker node update --label-add nginx=true $(docker node inspect self --format "{{ .ID }}")
