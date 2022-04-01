#!/bin/bash

# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh )
# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) 2>&1 | tee /setup-host.log

function _setup_host_debian() {
    DEBIAN_FRONTEND=noninteractive

    apt update

    # install common packages
    # ncurses-term required to support putty-256color term in docker
    apt install -y apt-utils bash-completion tar ca-certificates curl ncurses-term

    # install profile
    source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-profile.sh)

    # load os release variables
    local VERSION_CODENAME=$(source /etc/os-release && echo $VERSION_CODENAME)

    # softvisio repository
    curl -fsSLo /usr/share/keyrings/softvisio-archive-keyring.gpg https://raw.githubusercontent.com/softvisio/deb/main/dists/keyring.gpg
    cat << EOF > /etc/apt/sources.list.d/softvisio.list
# deb [trusted=yes] https://raw.githubusercontent.com/softvisio/deb/main/ $(. /etc/os-release && echo $VERSION_CODENAME) main
deb [signed-by=/usr/share/keyrings/softvisio-archive-keyring.gpg] https://raw.githubusercontent.com/softvisio/deb/main/ $(. /etc/os-release && echo $VERSION_CODENAME) main
EOF

    (
        echo ===================
        echo ===================
        echo ===================
        echo =================== NON LOCAL 11111111111111111111
        echo =================== $DEBIAN_FRONTEND
        DEBIAN_FRONTEND=noninteractive
        echo =================== $DEBIAN_FRONTEND

        apt update
        apt install -y repo-docker repo-pgsql repo-google-chrome repo-google-cloud n

        # upgrade installed packages to the latest versions
        apt update
        apt full-upgrade -y
    )

    # cleanup
    apt autoremove -y
}

function _setup_host_redhat() {

    # install common profile
    curl -fsSLo /etc/profile.d/bash-config.sh https://raw.githubusercontent.com/softvisio/scripts/main/bashrc.sh

    # load os release variables
    . /etc/os-release

    # centos
    if [[ $ID == "centos" ]]; then

        # centos 8
        if [[ $VERSION_ID == "8" ]]; then

            # fix locale, https://github.com/CentOS/sig-cloud-instance-images/issues/71#issuecomment-538302151
            dnf install -y glibc-langpack-en
        fi

        # epel repo
        dnf install -y epel-release
    fi

    # softvisio/release repo
    dnf install -y dnf-plugins-core
    dnf copr -y enable softvisio/release

    # centos additional repos
    if [[ $ID == "centos" ]]; then
        dnf install -y 'dnf-command(config-manager)'

        # centos 8
        if [[ $VERSION_ID == "8" ]]; then
            dnf config-manager --set-enabled plus powertools
        fi
    fi

    # install repos
    dnf install -y repo-softvisio repo-pgsql repo-docker repo-google-chrome n
    source /etc/profile.d/n.sh

    # plenv
    # dnf install -y plenv
    # source /etc/profile.d/plenv.sh

    # upgrade installed packages to the latest versions
    dnf update -y

    # install common packages
    dnf install -y bash-completion ca-certificates tar bzip2

    # clean old kernels
    dnf remove --oldinstallonly || true
}

_setup_host_debian
