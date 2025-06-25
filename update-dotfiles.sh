#!/usr/bin/env bash

# update installed profiles
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh)

# install / update "public" profile
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

# install / update "private" profile
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

# install / update "deployment" profile
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) deployment

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

function update-dotfiles() {
    local dotfiles=$(
        cat << JSON
{
    "public": "zdm/dotfiles-public",
    "private": "zdm/dotfiles-private",
    "deployment": "zdm/dotfiles-deployment"
}
JSON
    )

    local script
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/dotfiles.sh")
    source <(echo "$script") "$dotfiles" "$@"
}

update-dotfiles "$@"
