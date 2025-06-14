#!/usr/bin/env bash

# echo "text-to-encrypt" | /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) encrypt $GITHUB_USERNAME

# echo "text-to-decrypt" | /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/ssh-crypt.sh) decrypt $GITHUB_USERNAME

set -e

function ssh-crypt() {
    local operation=$1
    local github_username=$2

    local public_keys=$(curl --fail --silent "https://github.com/${github_username}.keys") || ""

    if [[ $public_keys == "" ]]; then
        echo "Unable to get SSH public key from GitHub" >&2

        return 1
    fi

    # create signature of github_username, that will be used as secret
    local secret=$(ssh-keygen -Y sign -n ssh-crypt -q -f /dev/fd/4 4<<< "$public_keys" <<< "$github_username" 2> /dev/null) || ""

    if [[ $secret == "" ]]; then
        echo "Private SSH key not found" >&2

        return 1
    fi

    case "$operation" in
        encrypt)
            gpg --symmetric --armor --yes --batch --passphrase-fd=4 4<<< "$secret"
            ;;
        decrypt)
            gpg --decrypt --quiet --batch --passphrase-fd=4 4<<< "$secret"
            ;;
        *)
            echo "cat \"text\" | ssh-crypt encrypt \$github_username"
            echo "cat \"encrypted text\" | ssh-crypt decrypt \$github_username"

            return 1
            ;;
    esac
}

ssh-crypt "$@"
