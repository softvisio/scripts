#!/bin/bash

# source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-profile.sh)

curl -fsSLo ~/.bashrc https://raw.githubusercontent.com/softvisio/scripts/main/profile/.bashrc
curl -fsSLo ~/.inputrc https://raw.githubusercontent.com/softvisio/scripts/main/profile/.inputrc

mkdir -p /etc/postgresql-common
curl -fsSLo /etc/postgresql-common/psqlrc https://raw.githubusercontent.com/softvisio/scripts/main/profile/psqlrc

. ~/.bashrc
