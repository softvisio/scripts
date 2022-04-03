#!/bin/bash

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh)
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) public
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-profile.sh) private

LOCATION=~
TMP_LOCATION=$LOCATION/.cache/profiles/tmp

function _update_profile() {
    local type=$1

    (
        shopt -s dotglob

        # remove profile files
        if [ -f $LOCATION/.cache/profiles/$type.txt ]; then
            for file in $(cat $LOCATION/.cache/profiles/$type.txt); do
                rm -f "$LOCATION/$file"
            done
        fi

        # create profile files list
        mkdir -p $LOCATION/.cache/profiles
        find $TMP_LOCATION/profile -type f -printf "%P\n" > $LOCATION/.cache/profiles/$type.txt

        # chmod
        chmod -R u=rw,go= $TMP_LOCATION/profile/*

        # git hooks must be executable
        if [[ -d $TMP_LOCATION/profile/.git-hooks ]]; then
            chmod +x $TMP_LOCATION/profile/.git-hooks/*
        fi

        # move profile
        yes | cp -rf $TMP_LOCATION/profile/* $LOCATION/ 2> /dev/null

        # remove tmp location
        rm -rf $TMP_LOCATION
    )
}

function _update_public_profile() {
    echo Updating public profile

    rm -rf $TMP_LOCATION
    mkdir -p $TMP_LOCATION

    curl -fsSL https://github.com/zdm/dotfiles-public/archive/main.tar.gz | tar -C $TMP_LOCATION --strip-components=1 -xzf -

    _update_profile "public"

    # postgresql
    mkdir -p /var/run/postgresql

    # mkdir -p /etc/postgresql-common
    # curl -fsSLo /etc/postgresql-common/psqlrc https://raw.githubusercontent.com/zdm/dotfiles-public/main/profile/.psqlrc

    if [ -f $LOCATION/.bashrc ]; then source $LOCATION/.bashrc; fi
}

function _update_private_profile() {
    echo Updating private profile

    rm -rf $TMP_LOCATION

    git clone git@github.com:zdm/dotfile-private.git $TMP_LOCATION

    _update_profile "private"
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

        if [ -f $LOCATION/.cache/profiles/private.txt ]; then
            _update_private_profile
        fi

        ;;

esac
