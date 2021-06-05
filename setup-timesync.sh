#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh | /bin/bash

set -e
set -u

dnf -y install tzdata chrony

systemctl enable chronyd
systemctl restart chronyd

timedatectl set-timezone UTC
timedatectl set-ntp yes

chronyc sources
chronyc sourcestats
chronyc tracking

hwclock --systohc

timedatectl status
