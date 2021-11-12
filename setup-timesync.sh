#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh | /bin/bash

set -e
set -u

apt -y install tzdata chrony

systemctl enable chrony
systemctl restart chrony

timedatectl set-timezone UTC
timedatectl set-ntp yes

chronyc sources
chronyc sourcestats
chronyc tracking

hwclock --systohc

timedatectl status
