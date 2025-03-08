#!/usr/bin/env bash

# update installed components
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh)

# install "public" component
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

# install "deployment" component
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) deployment

# install "private" component
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

DOTFILES_HOME=~
DOTFILES_CACHE=$DOTFILES_HOME/.local/share/dotfiles
DOTFILES_TMP=$DOTFILES_CACHE/tmp

function _update_dotfiles() {
    local type=$1

    (
        shopt -s dotglob

        # remove profile files
        if [ -f $DOTFILES_CACHE/$type.txt ]; then
            for file in $(cat $DOTFILES_CACHE/$type.txt); do
                rm -f "$DOTFILES_HOME/$file"
            done
        fi

        # create profile files list
        mkdir -p $DOTFILES_CACHE
        find $DOTFILES_TMP/profile -type f -print0 | tr "\0" "\n" > $DOTFILES_CACHE/$type.txt

        # chmod
        find $DOTFILES_TMP/profile -type d -exec chmod u=rwx,go= {} \;
        find $DOTFILES_TMP/profile -type f -exec chmod go= {} \;

        # move profile
        yes | cp -rfp $DOTFILES_TMP/profile/* $DOTFILES_HOME/ 2> /dev/null || true

        # remove tmp location
        rm -rf $DOTFILES_TMP
    )
}

function _update_public_dotfiles() {
    (
        set -e

        echo 'Updating "public" profile'

        rm -rf $DOTFILES_TMP
        mkdir -p $DOTFILES_TMP

        curl -fsSL https://github.com/zdm/dotfiles-public/archive/main.tar.gz | tar -C $DOTFILES_TMP --strip-components=1 -xzf -

        _update_dotfiles "public"

        # postgresql
        # mkdir -p /etc/postgresql-common
        # curl -fsSLo /etc/postgresql-common/psqlrc https://raw.githubusercontent.com/zdm/dotfiles-public/main/profile/.psqlrc
    )

    # source .bashrc
    if [ -f $DOTFILES_HOME/.bashrc ]; then
        echo Source $DOTFILES_HOME/.bashrc

        source $DOTFILES_HOME/.bashrc
    fi
}

function _update_deployment_dotfiles() {
    (
        set -e

        echo 'Updating "deployment" profile'

        rm -rf $DOTFILES_TMP

        git clone -q --depth=1 git@github.com:zdm/dotfiles-deployment.git $DOTFILES_TMP

        _update_dotfiles "deployment"
    )
}

function _update_private_dotfiles() {
    (
        set -e

        echo 'Updating "private" profile'

        rm -rf $DOTFILES_TMP

        git clone -q --depth=1 git@github.com:zdm/dotfiles-private.git $DOTFILES_TMP

        _update_dotfiles "private"
    )
}

case "$1" in
    public)
        _update_public_dotfiles

        ;;
    deployment)
        _update_deployment_dotfiles

        ;;
    private)
        _update_private_dotfiles

        ;;
    *)
        _update_public_dotfiles

        if [ -f $DOTFILES_CACHE/deployment.txt ]; then
            _update_deployment_dotfiles
        fi

        if [ -f $DOTFILES_CACHE/private.txt ]; then
            _update_private_dotfiles
        fi

        ;;
esac
