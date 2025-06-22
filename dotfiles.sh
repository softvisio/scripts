#!/usr/bin/env bash

# install / update components
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/dotfiles.sh) "$dotfiles" $type

function dotfiles() {
    local dotfiles=$1
    local type=$2

    export DOTFILES_DESTINATION=~

    local dotfiles_cache=$DOTFILES_DESTINATION/.local/share/dotfiles

    function _update-dotfiles() {
        local type=$1
        local repo_slug=$2

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

        echo "Updating \"${type}\" profile from \"$repo_slug\""

        (
            set -e

            # download source
            clone=$(curl -sL -w "%{http_code}" -o /dev/null https://api.github.com/repos/$repo_slug)

            # public repo
            if [[ $clone == "200" ]]; then
                curl -fsSL "https://github.com/$repo_slug/archive/main.tar.gz" \
                    | tar -C $dotfiles_tmp --strip-components=1 -xzf -

            # private repo
            elif [[ $clone == "404" ]]; then
                git clone --quiet --depth=1 "git@github.com:$repo_slug.git" $dotfiles_tmp

            # error
            else
                exit 1
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
                        echo "Remove \"$file\""

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
            \cp -rfp "$DOTFILES_SOURCE"/* "$DOTFILES_DESTINATION"
        )

        if [[ $? -ne 0 ]]; then
            _dotfiles_error || return 1
        fi

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
        if [[ -z $type ]]; then
            for type in $(jq -r "keys | reverse[]" <<< "$dotfiles"); do
                if [ -f "$dotfiles_cache/$type.txt" ]; then
                    local repo_slug=$(jq -r ".$type" <<< "$dotfiles")

                    _update-dotfiles $type $repo_slug

                    if [[ $? -ne 0 ]]; then
                        return 1
                    fi
                fi
            done
        else
            local repo_slug=$(jq -r ".$type" <<< "$dotfiles")

            if [[ $repo_slug == "null" ]]; then
                echo "Dotfiles profile is not valid" >&2

                return 1
            else
                _update-dotfiles $type $repo_slug

                if [[ $? -ne 0 ]]; then
                    return 1
                fi
            fi
        fi
    fi
}

dotfiles "$@"
