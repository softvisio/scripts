#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh) $GPG_KEY_ID

set -e

github_username=zdm
encrypted_passphrase="jA0ECQMK6n87BxNaaeX_0kUBcrPzy1t9o6cyMJXX3T2SS3WNyXpmyxBA5tow8eyEbAFccIw5gADc-jE2-asJTwo8pYpxZmxQtoiA-I1gpah_NHThUdg="

gpg_key_id=$1

export GPG_TTY=$(tty)

# decrypt gpg passphrase
passphrase=$(echo $encrypted_passphrase | /usr/bin/env bash <(curl --fail --silent --show-error https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $github_username)

# cache passphrase for key and sub-keys
keygrips=$(gpg --list-secret-keys --with-keygrip $gpg_key_id | awk '/Keygrip/ { print $3 }')

for keygrip in $keygrips; do
    echo "$passphrase" | /usr/lib/gnupg/gpg-preset-passphrase --preset $keygrip
done
