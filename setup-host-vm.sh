#!/usr/bin/env bash

# vmware
# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-vm.sh")
# bash <(echo "$script") vmware

# wsl
# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host-vm.sh")
# bash <(echo "$script") wsl

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

# disable selinux
# sed -i -e '/SELINUX=enforcing/ s/=enforcing/=permissive/' /etc/selinux/config

# disable firewalld
# systemctl stop firewalld; systemctl disable firewalld

function __setup_user() {
    local username=zdm

    # create user
    useradd $username
    passwd -d $username

    # add existed user to wheel group
    usermod -a -G wheel $username

    # allow "wheel" group users to perform su without password
    sed -i -e '/#auth\s\+sufficient\s\+pam_wheel.so\s\+trust\s\+use_uid/ s/#auth/auth/' /etc/pam.d/su

    # allow users of "wheel" group perform any sudo commands without password
    sed -i -e '/#\s*%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL/ s/#\s*%wheel/%wheel/' /etc/sudoers

    # install SSH public key
    local script
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/install-ssh-public-key.sh")
    sudo -u $username bash <(echo "$script")
}

function _setup_host_vm() {
    export DEBIAN_FRONTEND=noninteractive

    # setup host
    local scrippt
    scrippt=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh")
    source <(echo "$script")

    # setup SSH
    scrippt=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/install-ssh-public-key.sh")
    bash <(echo "$script")
    scrippt=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-sshd.sh")
    bash <(echo "$script")

    case "${1:-}" in
        vmware)
            _setup_host_vmware
            ;;

        wsl)
            _setup_host_wsl
            ;;

        *)
            return 1
            ;;
    esac

    # enable unqualified single-label domains (NFQDN) resolution
    sed -i -r '/ResolveUnicastSingleLabel/c ResolveUnicastSingleLabel=yes' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved

    # prefer ipv4 over ipv6
    sed -i -r '/precedence ::ffff:0:0\/96  10$/c precedence ::ffff:0:0\/96  100' /etc/gai.conf

    apt-get install -y mc htop nvim

    # git
    apt-get install -y git git-lfs git-filter-repo git-crypt gh

    # node build env
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh")
    bash <(echo "$script") setup-build

    # install gcloud
    apt-get install -y google-cloud-sdk
    # XXX
    # $(gcloud info --format="value(basic.python_location)") -m pip install numpy

    # install postgresql client
    apt-get install -y postgresql-client-17

    # install docker
    apt-get install -y docker-ce

    # install tor
    apt-get install -y tor nyx
    sed -i -e '/SocksPort 9050/ s/9050/0.0.0.0:9050\nControlPort 0.0.0.0:9051/' /usr/share/tor/tor-service-defaults-torrc
    systemctl restart tor

    # install node
    fnm use --install-if-missing lts-latest
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-node.sh")
    bash <(echo "$script")

    # install private dotfiles profile
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/update-dotfiles.sh")
    source <(echo "$script") private

    echo Setup host finished, you need to reboot server
}

function _setup_host_vmware() {
    apt-get install -y open-vm-tools

    # enable timesync with host
    vmware-toolbox-cmd timesync enable

    # setup timesync
    local script
    script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh")
    bash <(echo "$script")

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

function _setup_host_wsl() {

    # install wsl.conf
    # https://learn.microsoft.com/en-us/windows/wsl/wsl-config#wslconf
    cat << EOF > /etc/wsl.conf
# https://learn.microsoft.com/en-us/windows/wsl/wsl-config#wslconf

# Automatically mount Windows drive when the distribution is launched
[automount]

# Set to true will automount fixed drives (C:/ or D:/) with DrvFs under the root directory set above.
# Set to false means drives won't be mounted automatically, but need to be mounted manually or with fstab.
enabled = true

# Sets the directory where fixed drives will be automatically mounted.
# root = /

# DrvFs-specific options can be specified.
# options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off"

# Sets the "/etc/fstab" file to be processed when a WSL distribution is launched.
mountFsTab = true

# Network host settings that enable the DNS server used by WSL 2.
# This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).
[network]
hostname = wsl
# generateHosts = false
# generateResolvConf = false

# Set whether WSL supports interop processes like launching Windows apps and adding path variables.
# Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
# [interop]
# enabled = false
# appendWindowsPath = false

# Set the user when launching a distribution with WSL.
[user]
default = root

[boot]
systemd = true
# command =
EOF

    # keep wsl running in the background
    apt-get install -y keychain

    cat << EOF > /etc/profile.d/keep-wsl-running.sh
#!/usr/bin/env bash

eval \$(keychain -q)
EOF

    # link dirs
    ln -fs /mnt/d/projects/* /var/local
    ln -fs /mnt/d/downloads /var/local

}

_setup_host_vm ${1:-}
