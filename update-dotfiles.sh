#!/usr/bin/env bash

# update installed components
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh)

# install "public" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

# install "deployment" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) deployment

# install "private" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

dotfiles_public_slug=zdm/dotfiles-public
dotfiles_public_clone=

dotfiles_private_slug=zdm/dotfiles-private
dotfiles_private_clone=1

dotfiles_deployment_slug=zdm/dotfiles-deployment
dotfiles_deployment_clone=1

function update-dotfiles() {
    local type=$1

    export DOTFILES_DESTINATION=~

    local dotfiles_cache=$DOTFILES_DESTINATION/.local/share/dotfiles

    function _update-dotfiles() {
        local type=$1
        local slug=$2
        local clone=$3

        local dotfiles_tmp=$(mktemp -d)
        export DOTFILES_SOURCE="$dotfiles_tmp/profile"

        function _dotfiles-cleanup() {
            rm -rf "$dotfiles_tmp"
        }

        function _dotfiles_error() {
            _dotfiles-cleanup

            echo "Update failed" >&2

            return 1
        }

        echo "Updating \"${type}\" profile"

        (
            set -e

            # download source
            if [[ $clone ]]; then
                git clone --quiet --depth=1 "git@github.com:$slug.git" $dotfiles_tmp
            else
                curl -fsSL "https://github.com/$slug/archive/main.tar.gz" | tar -C $dotfiles_tmp --strip-components=1 -xzf -
            fi

            # before update
            if [[ -f "$dotfiles_tmp/before-update.sh" ]]; then
                "$dotfiles_tmp/before-update.sh"
            fi

            # update
            shopt -s dotglob

            # remove profile files
            if [[ -f "$dotfiles_cache/$type.txt" ]]; then
                for file in $(cat "$dotfiles_cache/$type.txt"); do
                    if [[ ! -f "$DOTFILES_SOURCE/$file" ]]; then
                        rm -f "$DOTFILES_DESTINATION/$file"
                    fi
                done
            fi

            # create profile files list
            mkdir -p "$dotfiles_cache"
            find "$DOTFILES_SOURCE" -type f -print0 | tr "\0" "\n" > "$dotfiles_cache/$type.txt"

            # chmod
            find "$DOTFILES_SOURCE" -type d -exec chmod u=rwx,go= {} \;
            find "$DOTFILES_SOURCE" -type f -exec chmod go= {} \;

            # copy profile
            yes | cp -rfp "$DOTFILES_SOURCE/*" "$DOTFILES_DESTINATION/" 2> /dev/null || true
        ) || _dotfiles_error || return 1

        # after update
        if [[ -f "$dotfiles_tmp/after-update.sh" ]]; then
            source "$dotfiles_tmp/after-update.sh" || _dotfiles_error || return 1
        fi

        # cleanup
        _dotfiles-cleanup
    }

    # Msys
    if [ $(uname -o) = "Msys" ]; then
        echo "Msys is not supported" >&2

        return 1

    # other OS
    else

        case "$type" in
            public)
                _update-dotfiles "$type" dotfiles_public_slug dotfiles_public_clone || return 1

                ;;
            private)
                _update-dotfiles "$type" dotfiles_private_slug dotfiles_private_clone || return 1

                ;;
            deployment)
                _update-dotfiles "$type" dotfiles_deployment_slug dotfiles_deployment_clone || return 1

                ;;
            *)
                _update-dotfiles "public" dotfiles_public_slug dotfiles_public_clone || return 1

                if [ -f "$dotfiles_cache/deployment.txt" ]; then
                    _update-dotfiles "deployment" dotfiles_deployment_slug dotfiles_deployment_clone || return 1
                fi

                if [ -f "$dotfiles_cache/private.txt" ]; then
                    _update-dotfiles "private" dotfiles_private_slug dotfiles_private_clone || return 1
                fi

                ;;
        esac
    fi
}

update-dotfiles "$@"
