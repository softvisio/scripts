#!/usr/bin/env bash

# update installed components
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh)

# install "public" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

# install "deployment" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) deployment

# install "private" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

dotfiles_public_github_slug=zdm/dotfiles-public
dotfiles_private_github_slug=zdm/dotfiles-private
dotfiles_deployment_github_slug=zdm/dotfiles-deployment

dotfiles_home=~
dotfiles_cache=$dotfiles_home/.local/share/dotfiles
dotfiles_tmp=$dotfiles_cache/tmp

function _update_dotfiles() {
    local type=$1

    (
        shopt -s dotglob

        # remove profile files
        if [ -f $dotfiles_cache/$type.txt ]; then
            for file in $(cat $dotfiles_cache/$type.txt); do
                rm -f "$dotfiles_home/$file"
            done
        fi

        # create profile files list
        mkdir -p $dotfiles_cache
        find $dotfiles_tmp/profile -type f -print0 | tr "\0" "\n" > $dotfiles_cache/$type.txt

        # chmod
        find $dotfiles_tmp/profile -type d -exec chmod u=rwx,go= {} \;
        find $dotfiles_tmp/profile -type f -exec chmod go= {} \;

        # move profile
        yes | cp -rfp $dotfiles_tmp/profile/* $dotfiles_home/ 2> /dev/null || true

        # remove tmp location
        rm -rf $dotfiles_tmp
    )
}

function _update_public_dotfiles() {
    (
        set -e

        echo 'Updating "public" profile'

        rm -rf $dotfiles_tmp
        mkdir -p $dotfiles_tmp

        curl -fsSL "https://github.com/$dotfiles_public_github_slug/archive/main.tar.gz" | tar -C $dotfiles_tmp --strip-components=1 -xzf -

        _update_dotfiles "public"

        # postgresql
        # mkdir -p /etc/postgresql-common
        # curl -fsS -o /etc/postgresql-common/psqlrc https://raw.githubusercontent.com/zdm/dotfiles-public/main/profile/.psqlrc
    )

    # source .bashrc
    if [ -f $dotfiles_home/.bashrc ]; then
        # echo Source $dotfiles_home/.bashrc

        source $dotfiles_home/.bashrc
    fi
}

function _update_private_dotfiles() {
    (
        set -e

        echo 'Updating "private" profile'

        rm -rf $dotfiles_tmp

        git clone --quiet --depth=1 "git@github.com:$dotfiles_private_github_slug.git" $dotfiles_tmp

        # unlock
        if [[ -f "$dotfiles_tmp/unlock.sh" ]]; then
            "$dotfiles_tmp/unlock.sh" || true
        fi

        git -C $dotfiles_tmp crypt unlock

        _update_dotfiles "private"
    )
}

function _update_deployment_dotfiles() {
    (
        set -e

        echo 'Updating "deployment" profile'

        rm -rf $dotfiles_tmp

        git clone --quiet --depth=1 "git@github.com:$dotfiles_deployment_github_slug.git" $dotfiles_tmp

        # unlock
        if [[ -f "$dotfiles_tmp/unlock.sh" ]]; then
            "$dotfiles_tmp/unlock.sh" || true
        fi

        git -C $dotfiles_tmp crypt unlock

        _update_dotfiles "deployment"
    )
}

# Msys
if [ $(uname -o) = "Msys" ]; then
    echo "Msys is not supported" >&2
    exit 1
fi

case "$1" in
    public)
        _update_public_dotfiles

        ;;
    private)
        _update_private_dotfiles

        ;;
    deployment)
        _update_deployment_dotfiles

        ;;
    *)
        _update_public_dotfiles

        if [ -f $dotfiles_cache/deployment.txt ]; then
            _update_deployment_dotfiles
        fi

        if [ -f $dotfiles_cache/private.txt ]; then
            _update_private_dotfiles
        fi

        ;;
esac
