#!/usr/bin/env bash

# update installed components
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh)

# install "public" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

# install "private" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

# install "deployment" component
# source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) deployment

$DOTFILES=$(
    cat << JSON
{
    "public": "zdm/dotfiles-public",
    "private": "zdm/dotfiles-private",
    "deployment": "zdm/dotfiles-deployment"
}
JSON
)

source <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/dotfiles.sh) $DOTFILES "$@"
