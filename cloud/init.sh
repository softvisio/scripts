#!/usr/bin/env bash

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

function _setup_instance() {
    local script

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
}

function _setup_hostname() {
    local name
    name=$(curl -fsS -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name")

    local project_id
    project_id=$(curl -fsS -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/project/project-id")

    hostname $name.$project_id
    hostname > /etc/hostname
}

function _setup_docker() {
    apt-get install -y \
        docker-ce

    local init_docker

    init_docker=$(curl -fsS -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/init_docker") || true

    if [[ -n "$init_docker" ]]; then
        $init_docker
    fi
}

# setup instance
_setup_instance

# setup hostname
_setup_hostname

# setup docker
_setup_docker
