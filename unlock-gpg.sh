#!/usr/bin/env bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh")
# bash <(echo "$script") $GPG_KEY_ID

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

github_username=zdm
encrypted_passphrase="U2FsdGVkX1+/a3Qii8oNkFfDEVvYqtVHi7Nf2tNQ+18="

gpg_key_id=${1:-}

export GPG_TTY=$(tty)

# decrypt gpg passphrase
script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh")
passphrase=$(echo $encrypted_passphrase | bash <(echo "$script") decrypt $github_username)

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
