#!/bin/bash

# /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-sshd.sh)

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
GatewayPorts                    yes
EOF

chmod 600 /etc/ssh/sshd_config.d/0.conf

# restart sshd
service ssh restart
