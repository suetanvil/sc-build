#!/bin/bash

set -e

# cd to the checkout root directory
cd -P $(dirname "${BASH_SOURCE[0]}")

tag=Version-3.12.2

if [ -f /.dockerenv ] || [ -n "$GITHUB_ACTIONS" ]; then
    . /etc/lsb-release

    if [ "$DISTRIB_RELEASE" = 18.04 ]; then
        echo "Detected $DISTRIB_ID $DISTRIB_RELEASE; installing packages."
        bash build_scripts/linux-setup-ubuntu-18-docker.sh
    else
        # We only really use Ubuntu 18, but this might work on other
        # versions.
        echo "Unexpected Linux version; assuming Ubuntu and winging it."
        bash build_scripts/linux-setup.sh
    fi
fi

[ -d artifacts ] || mkdir artifacts
./build_scripts/build-on-linux.sh "$tag"

exit 0
