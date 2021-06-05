#!/bin/bash

# curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/dotfiles.sh | /bin/bash -s -- update
# curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/dotfiles.sh | /bin/bash -s -- remove

set -e

LOCAL=~
REMOTE=git@bitbucket.org:zdm/.dotfiles.git
REMOTE_BRANCH=main

function _update() {
    if [ ! -e $LOCAL/.git ]; then
        git init
        git remote add origin $REMOTE
    fi

    # fetching remote
    git fetch origin $REMOTE_BRANCH &>/dev/null

    # creating and checking out "backup" branch
    git checkout --orphan backup &>/dev/null || git checkout --force backup &>/dev/null

    git reset --hard &>/dev/null

    git rm --cached \* &>/dev/null || true

    # adding files, tracked by remote branch
    local IFS=$'\n'

    for file in $(git ls-tree --full-tree --name-only --full-name -r origin/$REMOTE_BRANCH); do
        if [ -f $file ]; then
            git add $file
        fi
    done

    # commiting "backup"
    if [[ $(git status -s -uno) ]]; then
        git commit -m"backup" --no-verify &>/dev/null

        echo .dotfiles backup created
    fi

    # creating branch if not exists and checkout
    git checkout -B $REMOTE_BRANCH origin/$REMOTE_BRANCH &>/dev/null

    git reset --hard &>/dev/null

    # chmod .git
    find $LOCAL/.git \
        \( -type d -exec chmod u=rwx,go= {} \; \) , \
        \( -type f -exec chmod u=rw,go= {} \; \)

    # chmod tracked files
    local IFS=$'\n'

    for file in $(git ls-tree --full-tree --name-only --full-name -r origin/$REMOTE_BRANCH); do
        if [[ "$file" == *.pl ]] || [[ "$file" == *.sh ]] || [[ "$file" == *.py ]]; then
            chmod u=rwx,go= "$file"
        else
            chmod u=rw,go= "$file"
        fi
    done

    chmod +x $LOCAL/.dotfiles/git-hooks/*

    echo .dotfiles updated
}

function _remove() {

    # restore latest backup
    git checkout --force backup &>/dev/null

    git reset --hard &>/dev/null

    # remove dotfiles repository
    rm -rf $LOCAL/.git

    echo .dotfiles removed, initial state restored
}

case "$1" in
update)
    pushd $LOCAL 1>/dev/null

    _update

    if [ -f $LOCAL/.bashrc ]; then source $LOCAL/.bashrc; fi
    ;;

remove)
    pushd $LOCAL 1>/dev/null

    _remove

    if [ -f $LOCAL/.bashrc ]; then source $LOCAL/.bashrc; fi

    # restore default command prompt
    export PS1="[\u@\h \W]\$ "
    ;;

*)
    return 1
    ;;
esac

popd 1>/dev/null
