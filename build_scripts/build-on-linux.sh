#!/bin/bash

# Script to build SuperCollider on Linux

# Fail on error
set -e

# Get configuration variables
root=$(cd -P $(dirname "${BASH_SOURCE[0]}")/..; pwd)
. "$root/config.sh"

ARTIFACTS="$root/artifacts"

SC_PREFIX=opt/SuperCollider         # Must be relative

# Number of threads; default to half of the system's available threads
[ -n "$THREADS" ] || \
    export THREADS=$(( $(grep processor /proc/cpuinfo | wc -l) - 1 ))
[ $THREADS = 0 ] && THREADS=1

function version_from_tag {
    local tag=$1
    echo $tag | sed -e 's/^Version-//'
}

# Installer name (from the tag) minus the '.run' extension
function installer_name {
    local tag=$1
    local suffix=$2
    echo SuperCollider-$(version_from_tag $tag)-linux$suffix
}

function build_tag {
    local tag="$1"
    local suffix="$2"
    local version=$(version_from_tag $tag)
    local installer=$(installer_name $tag $suffix).run
    local workroot=`pwd`
    local prefix="$SC_PREFIX/sc-$version$suffix"

    # Destination suitable for making a installer
    [ -d install_tmp ] && rm -rf install_tmp
    mkdir install_tmp

    # Now, do the actual build
    echo "Preparing the checkout."
    cd workdir/supercollider
    git reset --hard
    git clean -x -f -d
    git checkout -q $tag
    git submodule update --init --recursive
    git clean -x -f -d  # just in case

    echo "Running cmake"
    mkdir build
    cd build
    cmake \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH="/$prefix" \
          ..

    echo "Building..."
    make -j $THREADS

    # And choose an alternate installation directory that we can use
    # for tarring
    echo "Installing..."
    make DESTDIR="$workroot/install_tmp" install

    # Create a workdir for creating the installer
    cd $workroot
    mkdir -p selfinst_tmp/files

    # Tar up the installation tree
    cd $workroot/install_tmp/$prefix/
    echo "Creating tarball..."
    tar cf $workroot/selfinst_tmp/files/sc.tar .

    # Fetch the installation script
    cd $workroot/selfinst_tmp
    cp $root/support/makeself_installer.sh files/

    echo "Creating self-installer."
    local build_id="$(cd $root; git log -1 --pretty=format:%h) $(date -Iseconds)"
    makeself --bzip2 \
             files/ $installer sc-$version \
             ./makeself_installer.sh /opt/SuperCollider/sc-$version$suffix \
             "'$build_id'"

    echo "Moving to artifact repo."
    mv $installer "$ARTIFACTS"

    cd "$workroot"
}




function setup_workdir() {
    echo "Setting up environment."

    [ -d workdir ] || mkdir workdir
    [ -d $ARTIFACTS ] || mkdir $ARTIFACTS

    local cwd=`pwd`

    cd workdir/
    if [ ! -d supercollider ]; then
        git clone $remote_repo supercollider
    fi

    cd supercollider

    # Fetch/update the submodules.  We use the main branch because
    # older revisions use the (now) unsupported-by-github `git:` URL
    # scheme; it looks like getting the latest and then jumping back
    # to the tag still works.
    git checkout -q -f main
    git pull origin main
    git submodule update --init --recursive

    cd "$cwd"
}


tag=$1
suffix=$2
if [ -z "$tag" ]; then
    echo "Usage: build-on-linux.sh <commit> [suffix]"
    exit 1
fi

echo "Building SuperCollider $tag ($THREADS threads)"

cd $root
setup_workdir
build_tag "$tag" "$suffix"
