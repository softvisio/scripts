#!/usr/bin/env bash

# source <(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh")
# source <(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh") 2>&1 | tee /setup-host.log

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

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
        jq

    # install public dotfiles profile
    source <(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh") public

    # postgresql tmp files
    mkdir -p /etc/tmpfiles.d
    cat << EOF > /etc/tmpfiles.d/postgresql.conf
d /var/run/postgresql 0755 root root
EOF

    (
        export DEBIAN_FRONTEND=noninteractive

        # load os release variables
        local VERSION_ID=$(source /etc/os-release && echo $VERSION_ID)

        # softvisio repository
        /usr/bin/env bash <(curl -fsS "https://raw.githubusercontent.com/softvisio/deb/main/setup.sh") install

        apt-get update

        apt-get reinstall -y \
            repo-cloudflared \
            repo-docker \
            repo-git \
            repo-git-lfs \
            repo-github-cli \
            repo-google-cloud \
            repo-postgresql

        apt-get install -y n

        # upgrade installed packages to the latest versions
        apt-get update
        apt-get full-upgrade -y

        # cleanup
        apt-get autoremove -y
    )
}

_setup_host_debian
