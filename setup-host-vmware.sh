#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-vmware.sh | /bin/bash
# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-vmware.sh | /bin/bash 2>&1 | tee /setup-host.log

set -e

# disable selinux
# sed -i -e '/SELINUX=enforcing/ s/=enforcing/=permissive/' /etc/selinux/config

# disable firewalld
# systemctl stop firewalld; systemctl disable firewalld

# setup user
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
    sudo -u $USERNAME curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/install-auth-key.sh | /bin/bash

    chmod 600 /home/$USERNAME/.ssh/authorized_keys
    chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
}

function _setup_host_vmware() {
    DEBIAN_FRONTEND=noninteractive

    # setup host
    source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh)

    # enable SSH root login
    sed -i -r '/#*\s*PermitRootLogin.+/c PermitRootLogin yes' /etc/ssh/sshd_config

    # enable SSH agent forward
    sed -i -r '/#*\s*ForwardAgent.+/c ForwardAgent yes' /etc/ssh/ssh_config

    # enable UQDN
    sed -i -r '/ResolveUnicastSingleLabel/c ResolveUnicastSingleLabel=yes' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved.service

    # install SSH key
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/install-auth-key.sh | /bin/bash

    apt install -y open-vm-tools mc htop git git-lfs git-filter-repo nvim

    # enable timesync with host
    vmware-toolbox-cmd timesync enable

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

    # setup timesync
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh | /bin/bash

    # node build env
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh | /bin/bash -s -- setup

    # install software
    apt install -y google-cloud-sdk

    # install postgresql client
    apt install -y postgresql-client-14

    # install chrome
    apt install -y google-chrome-stable ttf-mscorefonts-installer

    # install docker
    apt install -y docker-ce

    # install private dotfiles
    source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh) private

    # install node
    source /etc/profile.d/n.sh
    n latest
    n rm latest
    n prune
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh | /bin/bash

    echo Setup vmware host finished, you need to reboot server
}

_setup_host_vmware
