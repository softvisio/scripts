#!/usr/bin/env bash

# update installed components
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh)

# install "public" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

# install "deployment" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) deployment

# install "private" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

function update-dotfiles() {
    local type=$1

    declare -A types

    types["public", "slug"]="zdm/dotfiles-public"
    types["public", "clone"]=""

    types["private", "slug"]="zdm/dotfiles-private"
    types["private", "clone"]=1

    types["deployment", "slug"]="zdm/dotfiles-deployment"
    types["deployment", "clone"]=1

    export DOTFILES_DESTINATION=~

    local dotfiles_cache=$DOTFILES_DESTINATION/.local/share/dotfiles

    function _update-dotfiles() {
        local type=$1
        local slug=${types[$type, "slug"]}
        local clone=${types[$type, "clone"]}

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
            find "$DOTFILES_SOURCE" -type f -printf "%P\n" > "$dotfiles_cache/$type.txt"

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
                _update-dotfiles "$type" || return 1

                ;;
            private)
                _update-dotfiles "$type" || return 1

                ;;
            deployment)
                _update-dotfiles "$type" || return 1

                ;;
            *)
                _update-dotfiles "public" || return 1

                if [ -f "$dotfiles_cache/deployment.txt" ]; then
                    _update-dotfiles "deployment" || return 1
                fi

                if [ -f "$dotfiles_cache/private.txt" ]; then
                    _update-dotfiles "private" || return 1
                fi

                ;;
        esac
    fi
}

update-dotfiles "$@"
