#!/bin/bash

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/pscp.sh)

function pscp() {
    printf "\033]0;__pw:"$(pwd)"\007"

    for file in "$@"; do
        printf "\033]0;__rv:"${file}"\007"
    done

    # printf "\033]0;__ti\007"
}

alias pscp="pscp"

pscp "$@"
