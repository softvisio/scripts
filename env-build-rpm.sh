#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-rpm.sh | /bin/bash

set -u
set -e

source <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh)

curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- setup

dnf -y install 'dnf-command(builddep)' git perl rpm-build rpmdevtools mc

# init rpmbuild
rpmdev-setuptree
