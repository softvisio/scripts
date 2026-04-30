#!/usr/bin/env bash

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

function _import_gpg_keys() {
    script=$(curl -fsS "https://raw.githubusercontent.com/zdm/apps/main/gpg/backup/restore-gpg-key-deployment@softvisio.net.sh") && bash <(echo "$script")

    script=$(curl -fsS "https://raw.githubusercontent.com/zdm/apps/main/gpg/backup/restore-gpg-public-keys.sh") && bash <(echo "$script")
}

function _setup_hostname() {
    local name
    name=$(curl -fsS -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name")

    local project_id
    project_id=$(curl -fsS -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/project/project-id")

    hostname $name.$project_id
    hostname > /etc/hostname
}

function _init_docker_node() {}

# setup host
script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh")
bash <(echo "$script")

# setup timesync
script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh")
bash <(echo "$script")

# install ssh public key
script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/install-ssh-public-key.sh")
bash <(echo "$script")

# setup sshd
script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-sshd.sh")
bash <(echo "$script")

# setup hostname
_setup_hostname

# install dotfiles deployment profile
_import_gpg_keys
update-dotfiles deployment

# install docker
apt-get install -y \
    docker-ce
# docker swarm init
# name=$(curl -fsS -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/[KEY]")

apt-get install -y \
    mc \
    htop

apt-get install -y \
    git \
    git-lfs \
    git-crypt

apt-get install -y \
    postgresql-client-18
