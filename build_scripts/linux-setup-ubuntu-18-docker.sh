
# Setup for an Ubuntu 18.04 Docker container

set -e

# cd to the project root
cd -P $(dirname "${BASH_SOURCE[0]}")/..

. build_scripts/linux-setup.sh

# Ubuntu 18's cmake is too old so we get the one from Kitware instead.
if [ ! -f /etc/apt/sources.list.d/kitware.list ]; then
    [ -x /usr/bin/cmake ] && apt-get remove -y cmake
    sudo apt-get install -y wget gpg

    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
        | gpg --dearmor - | \
        tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null

    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | \
        tee /etc/apt/sources.list.d/kitware.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y cmake
fi
