#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-macos.sh")

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

# set timezone
sudo systemsetup -settimezone UTC

# install brew
/usr/bin/env bash <(curl -fsS "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh")

# install brew packages
brew install bash wget htop mc nvim node cocoapods ios-sim

# setup bash
if ! grep -q "/usr/local/bin/bash" /etc/shells; then
    sudo /usr/bin/env bash << EOF
echo /usr/local/bin/bash >> /etc/shells
EOF

    sudo chsh -s /usr/local/bin/bash
fi

# install public dotfiles profile
# source <(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh") public
/usr/bin/env bash <(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh") public

# setup cocoapods environment
pod setup

# update cocoapods repositories
pod repo update

# npm install --global ios-sim npm
npm install --global cordova

# install xcode devel tools
xcode-select --install

# set the patb to the active devel dir
# sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
