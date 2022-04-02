#!/bin/bash

set -e

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) -- public
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) -- private

function _update_public_profile() {
    curl -fsSL https://github.com/zdm/dotfiles-public/archive/main.tar.gz | tar -C=~ --strip-components=2 -xzf - dotfiles-public-main/profile

    # postgresql
    mkdir -p /var/run/postgresql

    # mkdir -p /etc/postgresql-common
    # curl -fsSLo /etc/postgresql-common/psqlrc https://raw.githubusercontent.com/zdm/dotfiles-public/main/profile/psqlrc

    if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
}

function _update_private_profile() {
    echo Not implemented
}

case "$1" in
    public)
        _update_public_profile
        ;;

    private)
        _update_private_profile
        ;;

    *)
        return 1
        ;;
esac
