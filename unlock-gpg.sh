#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh) $GPG_KEY_ID

set -e

ENCRYPTED_PASSPHRASE="jA0ECQMKoaA8QHejnU3/0kUB1rX0sKD6cikB7eXjDI8SOgyExFwwEtigbvZbDWusgwWKANoGQThlaoErr1E8n+zZ+MabXGOScX6mHEW9t8yzjzqKFSg="
GITHUB_USERNAME=zdm

GPG_KEY_ID=$1

export GPG_TTY=$(tty)

# decrypt gpg passphrase
passphrase=$(echo $ENCRYPTED_PASSPHRASE | /usr/bin/env bash <(curl --fail --silent --show-error https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $GITHUB_USERNAME)

# cache gpg key
keygrips=$(gpg --fingerprint --with-keygrip $GPG_KEY_ID | awk '/Keygrip/ { print $3 }')

for keygrip in $keygrips; do
    echo "$passphrase" | /usr/lib/gnupg/gpg-preset-passphrase --preset --restricted $keygrip
done
