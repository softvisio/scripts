#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-macos.sh | /bin/bash

set -e

# install devel tools
xcode-select --install

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# set the patb for the active devel dir
# sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# install packages
brew install wget mc node cocoapods ios-sim

# setup pod
pod setup

# setup node
curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh | /bin/bash

# npm install --global ios-sim
