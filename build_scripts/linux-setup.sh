
set -e

. /etc/lsb-release

# GitHub Actions doesn't run as root.

# if [ "$UID" != 0 ]; then
#     echo "Must be run as root."
#     exit 1
# fi

apt-get update
apt-get install -y software-properties-common

apt-get install -y build-essential cmake makeself libjack-jackd2-dev \
        libsndfile1-dev libfftw3-dev libxt-dev libavahi-client-dev \
        libudev-dev git emacs

apt-get install -y qt5-default qt5-qmake qttools5-dev qttools5-dev-tools \
    qtdeclarative5-dev qtwebengine5-dev libqt5svg5-dev \
    libqt5websockets5-dev




