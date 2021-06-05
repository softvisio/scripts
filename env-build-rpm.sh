#!/bin/bash

# curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/env-build-rpm.sh | /bin/bash

set -u
set -e

source <(curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/setup-host.sh)

curl -fsSL https://bitbucket.org/softvisio/scripts/raw/main/env-build.sh | /bin/bash -s -- setup

dnf -y install 'dnf-command(builddep)' git perl rpm-build rpmdevtools mc

# init rpmbuild
rpmdev-setuptree
