#!/bin/bash

# source <( curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/bashrc.sh )

export TERM=putty-256color
export HISTCONTROL=ignoreboth:erasedups
export CLICOLOR=1

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PGUSER=postgres
export PGHOST=127.0.0.1

# root user
if [ "$(id -u)" == "0" ]; then
    export PS1="[\[\e[1;31m\]\u\[\e[0;31m\]@\[\e[1;31m\]\H\[\e[0m\]\w]\[\e[1;33m\]#\[\e[0m\] "

# regular user
else
    export PS1="[\[\e[1;32m\]\u\[\e[0;32m\]@\[\e[1;32m\]\H\[\e[0m\]\w]\[\e[1;33m\]>\[\e[0m\] "
fi

shopt -s cdspell cmdhist dirspell histappend nocaseglob no_empty_cmd_completion

bind "set completion-ignore-case on" 2>/dev/null

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'
alias less='less --no-init --raw-control-chars --ignore-case --quit-on-intr --squeeze-blank-lines --quit-if-one-screen'
alias autossh="autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3'"
alias pscp="source <( curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/pscp.sh )"
alias d="docker"
alias g="git"
alias s="softvisio-cli"

function update() {
    dnf -y update
    dnf -y remove --oldinstallonly || true
}
