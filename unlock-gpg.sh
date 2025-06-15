#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh) $EMAIL

set -e

ENCRYPTED_PASSPHRASE="jA0ECQMKoaA8QHejnU3/0kUB1rX0sKD6cikB7eXjDI8SOgyExFwwEtigbvZbDWusgwWKANoGQThlaoErr1E8n+zZ+MabXGOScX6mHEW9t8yzjzqKFSg="
GITHUB_USERNAME=zdm

GPG_KEY_ID=$1

export GPG_TTY=$(tty)

# decrypt gpg passphrase
PASSPHRASE=$(echo $ENCRYPTED_PASSPHRASE | /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $GITHUB_USERNAME)

echo $PASSPHRASE
return

# unlock gpg key
echo 1 | gpg --sign \
    --batch \
    --pinentry-mode=loopback \
    --passphrase $PASSPHRASE \
    --yes \
    --quiet \
    --armor \
    -o /dev/null \
    -u $GPG_KEY_ID
