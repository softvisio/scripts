#!/usr/bin/env bash

# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh )
# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) 2>&1 | tee /setup-host.log

function _setup_host_debian() {
    DEBIAN_FRONTEND=noninteractive

    apt-get update

    # install common packages
    apt-get install -y \
        apt-utils \
        bash-completion \
        tar \
        ca-certificates \
        curl

    # install public dotfiles profile
    source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

    # postgresql tmp files
    mkdir -p /etc/tmpfiles.d
    cat << EOF > /etc/tmpfiles.d/postgresql.conf
d /var/run/postgresql 0755 root root
EOF

    (
        DEBIAN_FRONTEND=noninteractive

        # load os release variables
        local VERSION_ID=$(source /etc/os-release && echo $VERSION_ID)

        # softvisio repository
        /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/deb/main/setup.sh) install

        apt-get update

        apt-get reinstall -y \
            repo-docker \
            repo-git \
            repo-git-lfs \
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
