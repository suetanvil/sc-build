#!/bin/bash

set -e

# cd to the checkout root directory
cd -P $(dirname "${BASH_SOURCE[0]}")


tag=Version-3.12.2

if [ -f /.dockerenv ]; then
    . /etc/lsb-release

    if [ "$DISTRIB_RELEASE" = 18.04 ]; then
        . build_scripts/linux-setup-ubuntu-18-docker.sh
    else
        # We only really use Ubuntu 18, but this might work on other
        # versions.
        . build_scripts/linux-setup.sh
    fi
fi

[ -d artifacts ] || mkdir artifacts
./build_scripts/build-on-linux.sh "$tag" \
    || true

exit 0


