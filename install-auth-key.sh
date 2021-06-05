#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/install-auth-key.sh | /bin/bash

set -e

KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgGl5iJafIaKHlqRu3u04xn90lU9mmbiiZmFYugfcol openpgp:0xD20031CE"

mkdir -m 700 ~/.ssh 2>/dev/null || true

if [[ ! -f ~/.ssh/authorized_keys ]] || ! grep -q "$KEY" ~/.ssh/authorized_keys; then
    cat <<EOF >>~/.ssh/authorized_keys
$KEY
EOF
fi

chmod 600 ~/.ssh/authorized_keys
