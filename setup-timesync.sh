#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh | /bin/bash

set -e

DEBIAN_FRONTEND=noninteractive

apt-get install -y tzdata chrony

systemctl enable chrony
systemctl restart chrony

timedatectl set-timezone UTC
timedatectl set-ntp yes
timedatectl set-local-rtc false

# chronyc sources
# chronyc sourcestats
# chronyc tracking

# not required, synchronized automatically every 11 minutes
# hwclock --systohc

timedatectl status
