#!/bin/bash

# /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/install-auth-key.sh)

set -e

KEY="ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAHxTsx4kSEnxw83QPe8aBfIihbXsjtVM4fAdyCi4wCmMiqkowrynLd/f4eFsTQXARa4hA1ZbmiQ1L7AzTh9e3+MTgDWb7xXGvuP7EOuJimmG5xV/EtKjKGealVwgIxBDmFLp0VrtFsJBRhPVHZz8WWL499Sxw9a2+XYSBSoNbW943+nMQ== openpgp:0xE35FD126"

mkdir -m 700 ~/.ssh 2> /dev/null || true

if [[ ! -f ~/.ssh/authorized_keys ]] || ! grep -q "$KEY" ~/.ssh/authorized_keys; then
    cat << EOF >> ~/.ssh/authorized_keys
# zdm public key
$KEY
EOF
fi

chmod 600 ~/.ssh/authorized_keys
