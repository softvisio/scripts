#!/bin/bash

# /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-vm.sh) vmware
# /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-vm.sh) wsl

set -e

# disable selinux
# sed -i -e '/SELINUX=enforcing/ s/=enforcing/=permissive/' /etc/selinux/config

# disable firewalld
# systemctl stop firewalld; systemctl disable firewalld

function __setup_user() {
    local USERNAME=zdm

    # create user
    useradd $USERNAME
    passwd -d $USERNAME

    # add existed user to wheel group
    usermod -a -G wheel $USERNAME

    # allow "wheel" group users to perform su without password
    sed -i -e '/#auth\s\+sufficient\s\+pam_wheel.so\s\+trust\s\+use_uid/ s/#auth/auth/' /etc/pam.d/su

    # allow users of "wheel" group perform any sudo commands without password
    sed -i -e '/#\s*%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL/ s/#\s*%wheel/%wheel/' /etc/sudoers

    # disable password authentication via ssh
    sed -i -e '/^PasswordAuthentication\s\+yes/ s/yes/no/' /etc/ssh/sshd_config

    # disable root login via ssh
    sed -i -e '/^#PermitRootLogin\s\+yes/ s/#PermitRootLogin\s\+yes/PermitRootLogin no/' /etc/ssh/sshd_config

    # place public ssh key
    chmod 700 /home/$USERNAME
    mkdir /home/$USERNAME/.ssh
    chmod 700 /home/$USERNAME/.ssh
    chown $USERNAME:$USERNAME /home/$USERNAME/.ssh

    # TODO test
    # install SSH key
    sudo -u $USERNAME /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/install-auth-key.sh)

    chmod 600 /home/$USERNAME/.ssh/authorized_keys
    chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
}

function _setup_ssh() {
    apt-get install -y openssh-server

    # enable SSH root login
    sed -i -r '/#*\s*PermitRootLogin.+/c PermitRootLogin yes' /etc/ssh/sshd_config

    # enable SSH agent forward
    sed -i -r '/#*\s*ForwardAgent.+/c ForwardAgent yes' /etc/ssh/ssh_config

    # install SSH key
    /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/install-auth-key.sh)

    service ssh restart
}

function _setup_host_vm() {
    DEBIAN_FRONTEND=noninteractive

    # setup host
    source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh)

    # setup SSH
    _setup_ssh

    # enable unqualified single-label domains (NFQDN) resolution
    sed -i -r '/ResolveUnicastSingleLabel/c ResolveUnicastSingleLabel=yes' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved

    # prefer ipv4 over ipv6
    sed -i -r '/precedence ::ffff:0:0\/96  10$/c precedence ::ffff:0:0\/96  100' /etc/gai.conf

    apt-get install -y mc htop git git-lfs git-filter-repo nvim

    # node build env
    /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh) setup-build

    # install gcloud
    apt-get install -y google-cloud-sdk
    # XXX
    # $(gcloud info --format="value(basic.python_location)") -m pip install numpy

    # install postgresql client
    apt-get install -y postgresql-client-17

    # install chrome
    apt-get install -y google-chrome-stable ttf-mscorefonts-installer

    # install docker
    apt-get install -y docker-ce

    # install tor
    apt-get install -y tor nyx
    sed -i -e '/SocksPort 9050/ s/9050/0.0.0.0:9050\nControlPort 0.0.0.0:9051/' /usr/share/tor/tor-service-defaults-torrc
    systemctl restart tor

    # install node
    source /etc/profile.d/n.sh
    n lts
    n rm lts
    n prune
    /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh)

    # install private dotfiles profile
    source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

    echo Setup host finished, you need to reboot server
}

function _setup_host_vmware() {
    apt-get install -y open-vm-tools

    # enable timesync with host
    vmware-toolbox-cmd timesync enable

    # setup timesync
    /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh)

    # mount hgfs, if not mounted
    if mountpoint -q -- "/mnt/hgfs"; then
        echo HGFS is already mounted
    else
        mkdir /mnt/hgfs 2> /dev/null || true
        mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs -o defaults,allow_other
    fi

    # update fstab
    if ! grep -q "/mnt/hgfs" "/etc/fstab"; then
        echo ".host:/ /mnt/hgfs fuse.vmhgfs-fuse defaults,allow_other 0 0" >> /etc/fstab
    fi

    # install hgfs symlinks for vmware workstation
    if [ -d /mnt/hgfs ]; then

        # link hgfs dirs
        ln -fs /mnt/hgfs/projects/* /var/local
        ln -fs /mnt/hgfs/downloads /var/local
    fi
}

# function _setup_host_wsl() {
# }

# _setup_host_vm

case "$1" in
    vmware)
        _setup_host_vmware
        ;;

    wsl)
        # _setup_host_wsl
        ;;

    *)
        return 1
        ;;
esac
