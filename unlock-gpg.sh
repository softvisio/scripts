#!/usr/bin/env -S bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/unlock-gpg.sh")
# bash <(echo "$script") $GPG_KEY_ID
# bash <(echo "$script") $GPG_KEY_ID get-passphrase

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

github_username=zdm

# quoted delimiter: no shell expansion inside the heredoc
gpg_keys=$(
    cat << 'JSON'
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

# set in the main flow (not in a subshell), so they are shared by all functions
ssh_crypt_script=""
preset_passphrase_bin=""

function _error() {
    echo "$1" >&2

    exit 1
}

function _find_preset_passphrase_bin() {
    local libexecdir bin

    libexecdir=$(gpgconf --list-dirs libexecdir 2> /dev/null || true)

    for bin in \
        "$libexecdir/gpg-preset-passphrase" \
        /usr/lib/gnupg/gpg-preset-passphrase \
        /usr/lib/gnupg2/gpg-preset-passphrase \
        /usr/libexec/gpg-preset-passphrase; do
        if [[ -x $bin ]]; then
            echo "$bin"

            return
        fi
    done

    echo "gpg-preset-passphrase not found" >&2

    return 1
}

function _get_encrypted_passphrase() {
    local key_id=$1

    # key id is passed as a jq variable, not interpolated into the filter
    jq -r --arg key_id "$key_id" '.[$key_id] // empty' <<< "$gpg_keys"
}

function _decrypt_passphrase() {
    local encrypted_passphrase=$1 passphrase

    # decrypt gpg passphrase
    passphrase=$(printf '%s\n' "$encrypted_passphrase" | bash <(printf '%s' "$ssh_crypt_script") decrypt "$github_username")

    printf '%s' "$passphrase"
}

function _precache_passphrase() {
    local key_id=$1 decrypted_passphrase=$2 keys keygrips keygrip

    # precache passphrase for key and sub-keys
    keys=$(gpg --list-secret-keys --with-keygrip "$key_id" 2> /dev/null || true)

    if [[ -z $keys ]]; then
        echo "⚠  Secret key not found: $key_id" >&2

        return
    fi

    keygrips=$(awk '/Keygrip/ { print $3 }' <<< "$keys")

    for keygrip in $keygrips; do
        printf '%s\n' "$decrypted_passphrase" | "$preset_passphrase_bin" --preset "$keygrip"
    done
}

function _unlock_key() {
    local key_id=$1 encrypted_passphrase decrypted_passphrase

    encrypted_passphrase=$(_get_encrypted_passphrase "$key_id")

    if [[ -z $encrypted_passphrase ]]; then
        _error "Unknown key id: $key_id"
    fi

    decrypted_passphrase=$(_decrypt_passphrase "$encrypted_passphrase")

    if [[ $action == get-passphrase ]]; then
        printf '%s' "$decrypted_passphrase"
    else
        _precache_passphrase "$key_id" "$decrypted_passphrase"
    fi
}

# validate arguments
if [[ -n $action && $action != get-passphrase ]]; then
    _error "Unknown action: $action"
fi

if [[ $action == get-passphrase && -z $gpg_key_id ]]; then
    _error "Key id is required for get-passphrase"
fi

# fetch ssh-crypt.sh only once
ssh_crypt_script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh")

if [[ $action != get-passphrase ]]; then
    preset_passphrase_bin=$(_find_preset_passphrase_bin)
fi

if [[ -z $gpg_key_id ]]; then
    key_ids=$(jq -r 'keys | reverse[]' <<< "$gpg_keys")

    while IFS= read -r key_id; do
        _unlock_key "$key_id"
    done <<< "$key_ids"
else
    _unlock_key "$gpg_key_id"
fi
