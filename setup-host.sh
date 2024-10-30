#!/bin/bash

# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh )
# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) 2>&1 | tee /setup-host.log

function _setup_host_debian() {
    DEBIAN_FRONTEND=noninteractive

    apt-get update

    # install common packages
    # ncurses-term required to support putty-256color term in docker
    apt-get install -y \
        apt-utils \
        bash-completion \
        tar \
        ca-certificates \
        curl \
        ncurses-term

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
        /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/apt/main/setup.sh) install

        apt-get update
        apt-get reinstall -y \
            repo-docker \
            repo-postgresql \
            repo-google-chrome \
            repo-google-cloud
        apt-get install -y n

        # upgrade installed packages to the latest versions
        apt-get update
        apt-get full-upgrade -y

        # cleanup
        apt-get autoremove -y
    )
}

_setup_host_debian
