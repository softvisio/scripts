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
    local secret_key_id=01
    local secret

    function create_secret() {
        local github_username=${1:-}
        local public_keys
        local secret

        public_keys=$(curl --fail --silent "https://github.com/${github_username}.keys") || public_keys=""

        if [[ $public_keys == "" ]]; then
            echo "User \"$github_username\" has no public SSH keys published on GitHub" >&2
            return 1
        fi

        # create AES-256 secret key
        secret=$(echo -n "$github_username" | ssh-keygen -Y sign -n ssh-crypt -q -f /dev/fd/4 4<<< "$public_keys" 2> /dev/null | openssl sha3-256) || secret=""

        # extract HEX digest
        secret=${secret##*= }

        if [[ ! $secret =~ ^[[:xdigit:]]{64}$ ]]; then
            echo "Private SSH key not found" >&2
            return 1
        fi

        echo -n "$secret"
    }

    case "$operation" in
        encrypt)
            secret=$(create_secret "$github_username")

            openssl cms \
                -encrypt \
                -stream \
                -binary \
                -aes-256-gcm \
                -secretkey "$secret" \
                -secretkeyid "$secret_key_id" \
                -outform DER \
                | openssl base64 -A
            ;;
        decrypt)
            secret=$(create_secret "$github_username")

            openssl base64 -d -A \
                | openssl cms \
                    -decrypt \
                    -binary \
                    -secretkey "$secret" \
                    -secretkeyid "$secret_key_id" \
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
