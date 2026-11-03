#!/usr/bin/env -S bash

# NOTE: only RSA or ED25519 keys are supported

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh")
#
# echo "text-to-encrypt" | bash <(echo "$script") encrypt $GITHUB_USERNAME
#
# echo "encrypted text" | bash <(echo "$script") decrypt $GITHUB_USERNAME

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

function ssh-crypt() {
    local operation=${1:-}
    local github_username=${2:-}
    local secret_key_id=ssh-crypt
    local secret_key_id_hex
    local secret

    # openssl cms requires secret key id in HEX
    secret_key_id_hex=$(printf %s "$secret_key_id" | od -An -tx1 | tr -d ' \n')

    function create_secret() {
        local github_username=${1:-}
        local secret_key_id=${2:-}
        local public_keys
        local secret
        local key

        public_keys=$(curl --fail --silent "https://github.com/${github_username}.keys") || public_keys=""

        if [[ $public_keys == "" ]]; then
            echo "User \"$github_username\" has no public SSH keys published on GitHub" >&2
            return 1
        fi

        # input key material: HEX of the deterministic signature of the secret key id
        secret=$(echo -n "$secret_key_id" | ssh-keygen -Y sign -n ssh-crypt -q -f /dev/fd/4 4<<< "$public_keys" 2> /dev/null | od -An -tx1 | tr -d ' \n') || secret=""

        if [[ ! $secret =~ ^([[:xdigit:]]{2})+$ ]]; then
            echo "Private SSH key not found" >&2
            return 1
        fi

        # derive AES-256 key using HKDF-SHA3-256 without salt (RFC 5869: salt defaults to HashLen zero bytes)
        # info = secret key id
        key=$(openssl kdf \
            -keylen 32 \
            -kdfopt digest:SHA3-256 \
            -kdfopt hexkey:"$secret" \
            -kdfopt info:"$secret_key_id" \
            HKDF) || key=""

        # openssl prints HEX with ":" separators
        key=${key//:/}

        if [[ ! $key =~ ^[[:xdigit:]]{64}$ ]]; then
            echo "Unable to derive key with HKDF" >&2
            return 1
        fi

        echo -n "$key"
    }

    case "$operation" in
        encrypt)
            secret=$(create_secret "$github_username" "$secret_key_id")

            openssl cms \
                -encrypt \
                -stream \
                -binary \
                -aes-256-gcm \
                -secretkey "$secret" \
                -secretkeyid "$secret_key_id_hex" \
                -outform DER \
                | openssl base64 -A
            ;;
        decrypt)
            secret=$(create_secret "$github_username" "$secret_key_id")

            openssl base64 -d -A \
                | openssl cms \
                    -decrypt \
                    -binary \
                    -secretkey "$secret" \
                    -inform DER
            ;;
        *)
            echo "Usage:"
            echo "echo \"text\" | ssh-crypt encrypt \$GITHUB_USERNAME"
            echo "echo \"encrypted text\" | ssh-crypt decrypt \$GITHUB_USERNAME"

            return 1
            ;;
    esac
}

ssh-crypt "$@"
