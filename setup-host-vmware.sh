#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-vmware.sh | /bin/bash
# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-vmware.sh | /bin/bash 2>&1 | tee /setup-host.log

set -e
set -u

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

    # setup host
    source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh) 2>&1 | tee /setup-host.log

    # enable SSH root login
    sed -i -r '/#*\s*PermitRootLogin.+/c PermitRootLogin yes' /etc/ssh/sshd_config

    # install SSH key
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/install-auth-key.sh | /bin/bash

    # setup SSH service
    systemctl enable sshd
    systemctl restart sshd

    dnf install -y open-vm-tools mc htop git git-lfs

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
    dnf install -y nvim postgresql14 msttcorefonts google-chrome-stable

    # install docker
    dnf install -y docker-ce
    systemctl start docker.service
    systemctl enable docker.service

    # install .dotfiles
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/dotfiles.sh | /bin/bash -s -- update

    # install node
    #     /bin/bash -l <(
    #         cat << EOF
    # n latest
    # n rm latest
    # n prune
    # curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh | /bin/bash
    # EOF
    #     )

    # install perl
    # dnf install -y perl-5.34.0
    # plenv global perl-5.34.0

    echo Setup vmware host finished.
    echo You need to reboot server
}

_setup_host_vmware
