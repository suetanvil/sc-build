
set -e

. /etc/lsb-release


# We may or may not need sudo (docker runs everything as root so it
# doesn't; GA does) but we need `sudo <cmd>` to be harmless so we
# install sudo if it's not already there.  And while we're here, we
# may as well do the initial update.
if which sudo 2>&1 > /dev/null; then
    echo "Updating..."
    sudo apt-get update -qq
else
    echo "No sudo; updating and then installing it..."
    apt-get update -qq
    apt-get install -y sudo
fi

echo "Installing dependencies"
sudo apt-get install -y software-properties-common

sudo apt-get install -y build-essential cmake makeself libjack-jackd2-dev \
        libsndfile1-dev libfftw3-dev libxt-dev libavahi-client-dev \
        libudev-dev git emacs

sudo apt-get install -y qt5-default qt5-qmake qttools5-dev qttools5-dev-tools \
    qtdeclarative5-dev qtwebengine5-dev libqt5svg5-dev \
    libqt5websockets5-dev

