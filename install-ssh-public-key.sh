#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/install-ssh-public-key.sh)

set -e

KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/nPzEIJ9FvODTzjuTvrk+h6b3mq1ilgsm7wQpYLVRP openpgp:0x490E6007"

mkdir -m 700 ~/.ssh 2> /dev/null || true

if [[ ! -f ~/.ssh/authorized_keys ]] || ! grep -q "$KEY" ~/.ssh/authorized_keys; then
    cat << EOF >> ~/.ssh/authorized_keys
# zdm public key
$KEY
EOF
fi

chmod 600 ~/.ssh/authorized_keys
