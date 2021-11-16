#!/bin/bash

# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh )
# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) 2>&1 | tee /setup-host.log

function _setup_host() {

    apt update

    # install common packages
    # ncurses-term required to support putty-256color term in docker
    apt install -y bash-completion tar ca-certificates curl ncurses-term
    DEBIAN_FRONTEND=noninteractive apt install -y tzdata

    # load os release variables
    VERSION_CODENAME=$(source /etc/os-release && echo $VERSION_CODENAME)

    # install common profile
    curl -fsSLo /etc/profile.d/bash-config.sh https://raw.githubusercontent.com/softvisio/scripts/main/bashrc.sh

    # softvisio repository
    cat << EOF > /etc/apt/sources.list.d/softvisio.list
deb [trusted=yes] https://media.githubusercontent.com/media/softvisio/deb/main/ $(. /etc/os-release && echo $VERSION_CODENAME) main
EOF

    apt update
    apt install -y repo-docker repo-pgsql repo-google-chrome n

    # upgrade installed packages to the latest versions
    apt update
    apt full-upgrade -y

    # cleanup
    apt autoremove -y
}

_setup_host
