#!/usr/bin/env bash

# update installed profiles
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh)

# install / update "public" profile
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

# install / update "private" profile
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

# install / update "deployment" profile
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) deployment

$dotfiles=$(
    cat << JSON
{
    "public": "zdm/dotfiles-public",
    "private": "zdm/dotfiles-private",
    "deployment": "zdm/dotfiles-deployment"
}
JSON
)

source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/dotfiles.sh) $dotfiles "$@"
