#!/bin/bash

# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh )
# source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) 2>&1 | tee /setup-host.log

function _setup_host() {

    # install common profile
    curl -fsSLo /etc/profile.d/bash-config.sh https://raw.githubusercontent.com/softvisio/scripts/main/bashrc.sh

    # install repos
    # XXX softvisio repository

    # postgres repository
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg-archive-keyring.gpg
    cat << EOF > /etc/apt/sources.list.d/pgdg.list
deb [signed-by=/usr/share/keyrings/pgdg-archive-keyring.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main
EOF

    # docker repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    cat << EOF > /etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOF

    # google chrome repository
    curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-archive-keyring.gpg
    cat << EOF > /etc/apt/sources.list.d/google-chrome.list
deb [signed-by=/usr/share/keyrings/google-archive-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main
EOF

    # n
    # XXX deb package, source /etc/profile.d/n.sh
    export N_PREFIX=/usr/n
    mkdir -p $N_PREFIX
    curl -fsSL https://github.com/tj/n/archive/master.tar.gz | tar -C $N_PREFIX --strip-components=1 -xz
    cat << EOF > /etc/profile.d/n.sh
#!/bin/sh

export N_PREFIX=/usr/n

NPM_PREFIX=\$(realpath ~)/.npm/bin

[[ :\$PATH: == *":\$NPM_PREFIX:"* ]] || PATH+=":\$NPM_PREFIX"

[[ :\$PATH: == *":\$N_PREFIX/bin:"* ]] || PATH+=":\$N_PREFIX/bin"
EOF

    # upgrade installed packages to the latest versions
    apt update -y
    apt full-upgrade -y

    # install common packages
    apt install -y bash-completion ca-certificates tar bzip2

    # clean old kernels
    apt autoremove
}

_setup_host
