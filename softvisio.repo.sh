#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/softvisio.repo.sh | /bin/bash

set -e

DIST=$(rpm -E %{?dist})
DIST=${DIST//[0-9]/}

cat <<EOF >/etc/yum.repos.d/softvisio.repo
[softvisio]
name                = Softvisio
baseurl             = https://media.githubusercontent.com/media/softvisio/rpm/main/repo/repo/$DIST\$releasever-\$basearch/
enabled             = 1
type                = rpm-md
gpgcheck            = 0
repo_gpgcheck       = 0
enabled_metadata    = 1
module_hotfixes     = 1
skip_if_unavailable = 1
EOF
