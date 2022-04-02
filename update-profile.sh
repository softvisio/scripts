#!/bin/bash

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh)
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) public
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) private

LOCATION=~
TMP_LOCATION=$LOCATION/_tmp_profile

function _move_profile() {
    (
        shopt -s dotglob

        chmod -R u=rw,go= $TMP_LOCATION/profile/*

        if [[ -d $TMP_LOCATION/.git-hooks ]]; then
            chmod +x $TMP_LOCATION/.git-hooks/*
        fi

        mv -f $TMP_LOCATION/profile/* $LOCATION/

        rm -rf $TMP_LOCATION
    )
}

function _update_public_profile() {
    echo Updating public profile

    rm -rf $TMP_LOCATION
    mkdir -p $TMP_LOCATION

    curl -fsSL https://github.com/zdm/dotfiles-public/archive/main.tar.gz | tar -C $TMP_LOCATION --strip-components=1 -xzf -

    _move_profile

    # postgresql
    mkdir -p /var/run/postgresql

    # mkdir -p /etc/postgresql-common
    # curl -fsSLo /etc/postgresql-common/psqlrc https://raw.githubusercontent.com/zdm/dotfiles-public/main/profile/psqlrc

    if [ -f $LOCATION/.bashrc ]; then source $LOCATION/.bashrc; fi
}

function _update_private_profile() {
    echo Updating private profile

    rm -rf $TMP_LOCATION

    git clone git@github.com:zdm/dotfile-private.git $TMP_LOCATION

    _move_profile
}

case "$1" in
    public)
        _update_public_profile

        ;;

    private)
        _update_private_profile

        ;;

    *)
        _update_public_profile

        if [ -f $LOCATION/.private-profile ]; then
            _update_private_profile
        fi

        ;;

esac
