#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh) $GPG_KEY_ID

set -e

encrypted_passphrase="jA0ECQMKoaA8QHejnU3/0kUB1rX0sKD6cikB7eXjDI8SOgyExFwwEtigbvZbDWusgwWKANoGQThlaoErr1E8n+zZ+MabXGOScX6mHEW9t8yzjzqKFSg="
github_username=zdm

gpg_key_id=$1

export GPG_TTY=$(tty)

# decrypt gpg passphrase
passphrase=$(echo $encrypted_passphrase | /usr/bin/env bash <(curl --fail --silent --show-error https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $github_username)

# cache passphrase for key and sub-keys
keygrips=$(gpg --fingerprint --with-keygrip $gpg_key_id | awk '/Keygrip/ { print $3 }')

for keygrip in $keygrips; do
    echo "$passphrase" | /usr/lib/gnupg/gpg-preset-passphrase --preset $keygrip
done
