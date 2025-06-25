#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/install-ssh-public-key.sh")

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/nPzEIJ9FvODTzjuTvrk+h6b3mq1ilgsm7wQpYLVRP openpgp:0x490E6007"

mkdir -m 700 ~/.ssh 2> /dev/null || true

if [[ ! -f ~/.ssh/authorized_keys ]] || ! grep -q "$key" ~/.ssh/authorized_keys; then
    cat << EOF >> ~/.ssh/authorized_keys
# zdm public key
$key
EOF
fi

chmod 600 ~/.ssh/authorized_keys
