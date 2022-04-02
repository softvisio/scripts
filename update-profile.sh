#!/bin/bash

set -e

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) all
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) public
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) private

function _update_public_profile() {
    echo Updating public profile

    curl -fsSL https://github.com/zdm/dotfiles-public/archive/main.tar.gz | tar -C ~ --strip-components=2 -xzf - dotfiles-public-main/profile

    # postgresql
    mkdir -p /var/run/postgresql

    # mkdir -p /etc/postgresql-common
    # curl -fsSLo /etc/postgresql-common/psqlrc https://raw.githubusercontent.com/zdm/dotfiles-public/main/profile/psqlrc

    if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
}

function _update_private_profile() {
    echo Updating private profile

    rm -rf ~/_private_profile_tmp

    git clone git@github.com:zdm/dotfile-private.git ~/_private_profile_tmp

    mv -f ~/_private_profile_tmp/profile/* ~/

    rm -rf ~/_private_profile_tmp
}

case "$1" in
    all)
        _update_public_profile
        _update_private_profile
        ;;

    public)
        _update_public_profile
        ;;

    private)
        _update_private_profile
        ;;

    *)
        echo Argument is required

        return 1
        ;;
esac
