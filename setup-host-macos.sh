#!/bin/bash

# /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-macos.sh)

set -e

# set timezone
sudo systemsetup -settimezone UTC

# install brew
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)

# install brew packages
brew install bash wget mc nvim node cocoapods ios-sim

# setup bash
sudo /bin/bash << EOF
	echo /usr/local/bin/bash >> /etc/shells
EOF

sudo chsh -s /usr/local/bin/bash

# install public dotfiles
# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) public

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
