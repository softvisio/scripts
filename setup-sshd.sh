#!/usr/bin/env bash

# NOTE https://man7.org/linux/man-pages/man5/sshd_config.5.html

# /usr/bin/env bash <(curl -fsS https://raw.githubusercontent.com/softvisio/scripts/main/setup-sshd.sh)

set -e

DEBIAN_FRONTEND=noninteractive

apt-get install -y openssh-server

cat << EOF > /etc/ssh/sshd_config.d/0.conf
KbdInteractiveAuthentication    no
PasswordAuthentication          no
PubkeyAuthentication            yes
PermitEmptyPasswords            no

AllowAgentForwarding            yes
AllowTcpForwarding              yes
AllowStreamLocalForwarding      yes
GatewayPorts                    yes
EOF

chmod 600 /etc/ssh/sshd_config.d/0.conf

# restart sshd
service ssh restart
