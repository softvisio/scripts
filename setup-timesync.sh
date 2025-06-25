#!/usr/bin/env bash

# bash <(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh")

set -Eeuo pipefail
trap 'echo -e "⚠  Error ($0:$LINENO): $(sed -n "${LINENO}p" "$0" 2> /dev/null | grep -oE "\S.*\S|\S" || true)" >&2; return 3 2> /dev/null || exit 3' ERR

export DEBIAN_FRONTEND=noninteractive

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
