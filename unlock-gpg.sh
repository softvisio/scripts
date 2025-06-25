#!/usr/bin/env bash

# /usr/bin/env bash <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh) $GPG_KEY_ID

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

github_username=zdm
encrypted_passphrase="jA0ECQMIjlbQquxJ6tTq0kUB-_owraL1se7wve5kEjl3oKjZRt6yPKO6kep87bdEHoZSh-mpPHS-fpLreWBERaqjfs_r_vPMidfU73yCGDl5Ym3s9Ew="

gpg_key_id=$1

export GPG_TTY=$(tty)

# decrypt gpg passphrase
passphrase=$(echo $encrypted_passphrase | /usr/bin/env bash <(curl --fail --silent --show-error https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $github_username)

case "${1:-}" in
    passphrase)
        echo $passphrase
        ;;
    *)
        # cache passphrase for key and sub-keys
        keygrips=$(gpg --list-secret-keys --with-keygrip $gpg_key_id | awk '/Keygrip/ { print $3 }')

        for keygrip in $keygrips; do
            echo "$passphrase" | /usr/lib/gnupg/gpg-preset-passphrase --preset $keygrip
        done
        ;;
esac
