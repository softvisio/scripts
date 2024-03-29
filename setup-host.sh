#!/bin/bash

# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh )
# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) 2>&1 | tee /setup-host.log

function _setup_host_debian() {
    DEBIAN_FRONTEND=noninteractive

    apt-get update

    # install common packages
    # ncurses-term required to support putty-256color term in docker
    apt-get install -y apt-utils bash-completion tar ca-certificates curl ncurses-term

    # install public dotfiles
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
        curl -fsSLo /usr/share/keyrings/softvisio-archive-keyring.gpg https://raw.githubusercontent.com/softvisio/deb/main/dists/keyring.gpg
        cat << EOF > /etc/apt/sources.list.d/softvisio.list
# deb [trusted=yes] https://raw.githubusercontent.com/softvisio/deb/main/ $(. /etc/os-release && echo $VERSION_ID) main
deb [signed-by=/usr/share/keyrings/softvisio-archive-keyring.gpg] https://raw.githubusercontent.com/softvisio/deb/main/ $(. /etc/os-release && echo $VERSION_ID) main
EOF

        apt-get update
        apt-get install -y repo-docker repo-postgresql repo-google-chrome repo-google-cloud n

        # upgrade installed packages to the latest versions
        apt-get update
        apt-get full-upgrade -y

        # cleanup
        apt-get autoremove -y
    )
}

_setup_host_debian
