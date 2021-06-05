#!/bin/bash

# curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/softvisio.repo.sh | /bin/bash

set -e

DIST=$(rpm -E %{?dist})
DIST=${DIST//[0-9]/}

cat <<EOF >/etc/yum.repos.d/softvisio.repo
[softvisio]
name                = Softvisio
baseurl             = https://bitbucket.org/softvisio/rpm/raw/main/repo/$DIST\$releasever-\$basearch/
enabled             = 1
type                = rpm-md
gpgcheck            = 0
repo_gpgcheck       = 0
enabled_metadata    = 1
module_hotfixes     = 1
skip_if_unavailable = 1
EOF
