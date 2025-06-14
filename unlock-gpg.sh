#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh) $EMAIL

set -e

GPG_KEY_ID=$1
GITHUB_USERNAME=zdm

export GPG_TTY=$(tty)

# decrypt gpg passphrase
PASSPHRASE=$(
    cat << EOF | /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $GITHUB_USERNAME
-----BEGIN PGP MESSAGE-----

jA0ECQMKXDVY3ahL2bX/0kUBRnHUDM2IymQDwGBgGOq/Qs+1CJemX6OrcO9+2yUE
W0Xc9tU2z9zoxekpG0lnLth4XmUf+oKjXAqVbuS917dvI9j+iRU=
=hjeI
-----END PGP MESSAGE-----
EOF
)

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
