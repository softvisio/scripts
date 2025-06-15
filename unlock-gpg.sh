#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh) $EMAIL

set -e

ENCRYPTED_PASSPHRASE=jA0ECQMKtZzcWNcSOXf/0kUB+XWe3203WQ4Q4J2kP/FhLww7t41JF0RxcvGTfg9cD5pUCxtw8MqwDW+oh48uJ5re83WegZUOspdEIWzbaCTOKZH5DGE=
GITHUB_USERNAME=zdm

GPG_KEY_ID=$1

export GPG_TTY=$(tty)

# decrypt gpg passphrase
PASSPHRASE=$(echo $ENCRYPTED_PASSPHRASE | /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $GITHUB_USERNAME)

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
