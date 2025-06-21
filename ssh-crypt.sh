#!/usr/bin/env bash

# NOTE: only RSA or ED25519 keys are supported

# echo "text-to-encrypt" | /usr/bin/env bash <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) encrypt $GITHUB_USERNAME

# echo "text-to-decrypt" | /usr/bin/env bash <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $GITHUB_USERNAME

set -e

function ssh-crypt() {
    local operation=$1
    local github_username=$2
    local secret

    function create_secret() {
        local github_username=$1
        local public_keys=$(curl --fail --silent "https://github.com/${github_username}.keys") || ""

        if [[ $public_keys == "" ]]; then
            echo "Unable to get SSH public key from GitHub" >&2

            return 1
        fi

        # create signature of github_username, that will be used as secret
        secret=$(ssh-keygen -Y sign -n ssh-crypt -q -f /dev/fd/4 4<<< "$public_keys" <<< "$github_username" 2> /dev/null | gpg --dearmor 2> /dev/null | basenc --base64url --wrap=0) || ""

        if [[ $secret == "" ]]; then
            echo "Private SSH key not found" >&2

            return 1
        fi
    }

    case "$operation" in
        encrypt)
            create_secret $github_username

            echo $(gpg --symmetric --batch --passphrase-fd=4 4<<< "$secret" | basenc --base64url --wrap=0)
            ;;
        decrypt)
            create_secret $github_username

            basenc --base64url --decode | gpg --decrypt --quiet --batch --passphrase-fd=4 4<<< "$secret"
            ;;
        *)
            echo "echo \"text\" | ssh-crypt encrypt \$GITHUB_USERNAME"
            echo "echo \"encrypted text\" | ssh-crypt decrypt \$GITHUB_USERNAME"

            return 1
            ;;
    esac
}

ssh-crypt "$@"
