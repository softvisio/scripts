#!/usr/bin/env bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh")
# bash <(echo "$script") $GPG_KEY_ID
# bash <(echo "$script") $GPG_KEY_ID get-passphrase

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

github_username=zdm
gpg_keys=$(
    cat << JSON
{
    "dzagashev@gmail.com":      "U2FsdGVkX1+hSMAl+SljhhnDHE7EXcIjHgypuflLrs9y37YDXqCM9ioN/1B7lYC0",
    "deb@softvisio.net":        "U2FsdGVkX1/+V6USDRFBjl/G9CZLI7ksk/bgXE5STTorgpu7jT9vTkr40IfCzS0N",
    "deployment@softvisio.net": "U2FsdGVkX19UVy1HE6ezTeCZ6CoOkPTRO/e0WTlf2JFPHa4k7GnygbtAR7gpoKGT"
}
JSON
)

gpg_key_id=${1:-}
action=${2:-}

function _decrypt_passphrase() {
    encrypted_passphrase=$1

    # decrypt gpg passphrase
    local script
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh")
    passphrase=$(echo "$encrypted_passphrase" | bash <(echo "$script") decrypt "$github_username")

    echo -n "$passphrase"
}

function _precache_passphrase() {
    local key_id=$1
    local decrypted_passphrase=$2

    # precache passphrase for key and sub-keys
    keygrips=$(gpg --list-secret-keys --with-keygrip "$key_id" | awk '/Keygrip/ { print $3 }')

    for keygrip in $keygrips; do
        echo "$decrypted_passphrase" | /usr/lib/gnupg/gpg-preset-passphrase --preset $keygrip
    done
}

if [[ -z $gpg_key_id ]]; then
    for key_id in $(jq -r "keys | reverse[]" <<< "$gpg_keys"); do
        encrypted_passphrase=$(jq -r ".\"$(echo $key_id)\"" <<< "$gpg_keys")
        decrypted_passphrase=$(_decrypt_passphrase $encrypted_passphrase)

        _precache_passphrase "$key_id" "$decrypted_passphrase"
    done
else
    encrypted_passphrase=$(jq -r ".\"$(echo $gpg_key_id)\"" <<< "$gpg_keys")
    decrypted_passphrase=$(_decrypt_passphrase $encrypted_passphrase)

    if [[ "$action" == "get-passphrase" ]]; then
        echo -n "$decrypted_passphrase"
    else
        _precache_passphrase "$gpg_key_id" "$decrypted_passphrase"
    fi
fi
