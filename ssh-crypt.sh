#!/usr/bin/env bash

# NOTE: only RSA or ED25519 keys are supported

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh")
#
# echo "text-to-encrypt" | bash <(echo "$script") encrypt $GITHUB_USERNAME
#
# echo "text-to-decrypt" | bash <(echo "$script") decrypt $GITHUB_USERNAME

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

function ssh-crypt() {
    local operation=${1:-}
    local github_username=${2:-}
    local secret
    local openssl_options="enc -a -A -aes-256-cbc -pbkdf2"

    function create_secret() {
        local github_username=${1:-}
        local public_keys=$(curl --fail --silent "https://github.com/${github_username}.keys") || ""
        local secret

        if [[ $public_keys == "" ]]; then
            echo "User \"$github_username\" has no public SSH keys published on GitHub" >&2

            return 1
        fi

        # create AES-256 secret key
        secret=$(echo -n "$github_username" | ssh-keygen -Y sign -n ssh-crypt -q -f /dev/fd/4 4<<< "$public_keys" 2> /dev/null | openssl dgst -sha3-256 -binary) || ""

        if [[ $secret == "" ]]; then
            echo "Private SSH key not found" >&2

            return 1
        fi

        echo -n "$secret"
    }

    case "$operation" in
        encrypt)
            secret=$(create_secret $github_username)

            local encrypted
            encrypted=$(openssl $openssl_options -k "$secret" -e)

            echo "$encrypted"
            ;;
        decrypt)
            secret=$(create_secret $github_username)

            openssl $openssl_options -k "$secret" -d
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
