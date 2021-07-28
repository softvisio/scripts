#!/bin/bash

# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-perl.sh | /bin/bash -s -- setup
# curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-perl.sh | /bin/bash -s -- cleanup

set -e
set -u

function _setup() {

    # setup build env
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- setup

    local PACKAGES=""

    # OpenSSL libs
    PACKAGES="$PACKAGES openssl-devel"

    # perl DB_File
    PACKAGES="$PACKAGES libdb-devel"

    # perl Term::ReadLine::Gnu
    PACKAGES="$PACKAGES ncurses-devel readline-devel"

    # perl Pcore::Util::IDN
    PACKAGES="$PACKAGES libidn2-devel"

    # perl Pcore::GeoIP
    PACKAGES="$PACKAGES libmaxminddb-devel"

    # perl Net::LibIDN
    PACKAGES="$PACKAGES libidn-devel"

    # perl XML::Simple
    PACKAGES="$PACKAGES expat-devel"

    # perl XML::LibXML
    PACKAGES="$PACKAGES libxml2-devel"

    # perl Imager
    PACKAGES="$PACKAGES libjpeg-devel giflib-devel libtiff-devel libpng-devel libwebp-devel freetype-devel"

    # perl Authen::SASL::XS
    PACKAGES="$PACKAGES cyrus-sasl-devel"

    dnf -y install $PACKAGES
}

function _cleanup() {
    local PACKAGES=""

    # OpenSSL libs
    # NOTE do not remove, because nginx depends on it
    # PACKAGES="$PACKAGES openssl openssl-devel"

    # perl DB_File
    PACKAGES="$PACKAGES libdb-devel"

    # perl Term::ReadLine::Gnu
    PACKAGES="$PACKAGES ncurses-devel readline-devel"

    # perl Pcore::Util::IDN
    PACKAGES="$PACKAGES libidn2-devel"

    # perl Pcore::GeoIP
    PACKAGES="$PACKAGES libmaxminddb-devel"

    # perl Net::LibIDN
    PACKAGES="$PACKAGES libidn-devel"

    # perl XML::Simple
    PACKAGES="$PACKAGES expat-devel"

    # perl XML::LibXML
    PACKAGES="$PACKAGES libxml2-devel"

    # perl Imager
    PACKAGES="$PACKAGES libjpeg-devel giflib-devel libtiff-devel libpng-devel libwebp-devel freetype-devel"

    # perl Authen::SASL::XS
    PACKAGES="$PACKAGES cyrus-sasl-devel"

    dnf -y autoremove $PACKAGES

    # cleanup build env
    curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build.sh | /bin/bash -s -- cleanup
}

case "$1" in
    setup)
        _setup
        ;;

    cleanup)
        _cleanup
        ;;

    *)
        return 1
        ;;
esac
