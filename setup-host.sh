#!/usr/bin/env bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh")
# source <(echo "$script")
# source <(echo "$script") 2>&1 | tee /setup-host.log

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

function _setup_host_debian() {
    export DEBIAN_FRONTEND=noninteractive

    apt-get update

    # install common packages
    apt-get install -y \
        apt-utils \
        bash-completion \
        tar \
        ca-certificates \
        curl \
        less \
        sudo \
        jq

    # install public dotfiles profile
    local script
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh")
    source <(echo "$script") public

    # postgresql tmp files
    mkdir -p /etc/tmpfiles.d
    cat << EOF > /etc/tmpfiles.d/postgresql.conf
d /var/run/postgresql 0755 root root
EOF

    (
        export DEBIAN_FRONTEND=noninteractive

        # instal  softvisio repository
        script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/deb-repository/main/setup.sh")
        bash <(echo "$script") install

        apt-get update

        apt-get reinstall -y \
            docker.repository \
            git.repository \
            git-lfs.repository \
            google-cloud.repository \
            postgresql.repository

        # upgrade installed packages to the latest versions
        apt-get update
        apt-get full-upgrade -y
    )

    # fnm
    apt-get install -y fnm
    source /etc/profile.d/fnm.sh

    # cleanup
    apt-get autoremove -y
}

_setup_host_debian
