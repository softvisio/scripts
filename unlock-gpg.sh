#!/usr/bin/env -S bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh")
# bash <(echo "$script") $GPG_KEY_ID
# bash <(echo "$script") $GPG_KEY_ID get-passphrase

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

github_username=zdm
gpg_keys=$(
    cat << JSON
{
    "dzagashev@gmail.com":
    "MIAGCyqGSIb3DQEJEAEXoIAwgAIBADFJokcCAQQwCwQJc3NoLWNyeXB0MAsGCWCGSAFlAwQBLQQonUwnZr5OSkCbq+o15zNTHOsdOrtMe7J/+8L790oGUHWgogswktl7ZjCABgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDKGnXR0zMsSEYPwjsAIBEKCABA/V34jFnusmaMFXTM0RPHkAAAAABBCc5e/A6AZEfP8QcL0uj16+AAAAAAAA",

    "deb@softvisio.net":
    "MIAGCyqGSIb3DQEJEAEXoIAwgAIBADFJokcCAQQwCwQJc3NoLWNyeXB0MAsGCWCGSAFlAwQBLQQogQ2c2rabZrafokGxBEc0NLx3uCBd/iiX18SwvZjqhT58UwlfyQ47jzCABgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDNas6x3bC0W6XX8EdQIBEKCABCQtibZ0NhNIf62XhMAXX+GMh1JcAnW9BzpLXolEnZNb3s37R6EAAAAABBB4woMdf6ukG+ByQiJYvcTYAAAAAAAA",

    "deployment@softvisio.net":
    "MIAGCyqGSIb3DQEJEAEXoIAwgAIBADFJokcCAQQwCwQJc3NoLWNyeXB0MAsGCWCGSAFlAwQBLQQoGuE8WyXjgCdEQwgT3I64pZpyEjD5G1cXRjJaSLKmwjvSrYyRCP/aBjCABgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDAT3/JIM3Gn3P2vgxwIBEKCABCSKaM9VRBJfhdEfpywjKDRC7E47R/D0BceBtqEYxmyH5NwUQ9wAAAAABBBoaz2Nd9NBQasIhhvNFuv3AAAAAAAA"
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
    keys=$(gpg --list-secret-keys --with-keygrip "$key_id" 2> /dev/null || true)

    if [[ -z $keys ]]; then
        return
    fi

    keygrips=$(echo "$keys" | awk '/Keygrip/ { print $3 }')

    for keygrip in $keygrips; do
        echo "$decrypted_passphrase" | /usr/lib/gnupg/gpg-preset-passphrase --preset $keygrip
    done
}

if [[ -z $gpg_key_id ]]; then
    for key_id in $(jq -r "keys | reverse[]" <<< "$gpg_keys"); do
        key_id=$(echo "$key_id")

        encrypted_passphrase=$(jq -r ".\"$key_id\"" <<< "$gpg_keys")
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
