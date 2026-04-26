#!/usr/bin/env bash

# script=$(curl -fsS "https://raw.githubusercontent.com/softvisio/scripts/main/setup-timesync.sh")
# bash <(echo "$script")

set -Eeuo pipefail
trap 'echo "⚠  Error ($0:$LINENO, exit code: $?): $BASH_COMMAND" >&2' ERR

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
