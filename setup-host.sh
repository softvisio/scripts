#!/bin/bash

# source <( curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/setup-host.sh )
# source <( curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/setup-host.sh ) 2>&1 | tee /setup-host.log

function _setup_host() {

    # install common profile
    curl -fsSLo /etc/profile.d/bash-config.sh https://bitbucket.org/softvisio/scripts/raw/main/bashrc.sh

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

_setup_host
