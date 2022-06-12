#!/bin/bash

# Installer script run by the self-installer.

set -e

umask 0022

install_dir=$1          # /opt/SuperCollider/sc-(version)/
package_id=$2           # Timestamp or build script commit ID

if [ -d "$install_dir" ]; then
    echo "Directory '$install_dir' already exists. Delete or move it first."
    exit 1
fi

echo "Installing SuperCollider in $install_dir..."
if mkdir -p "$install_dir"; then
    true
else
    echo "Unable to create installation directory '$install_dir'."
    echo "Are you sure you have permission?"
    exit 1
fi

src_dir=`pwd`
cd "$install_dir"
tar xf "$src_dir/sc.tar"

echo "Creating launch scripts..."
mv bin exec
mkdir bin
for exe in exec/*; do
    (
        set -e
        echo "#!/bin/sh"
        echo "PATH=\"$install_dir/exec/:\$PATH\"; export PATH"
        echo "exec $install_dir/exec/$(basename $exe) \"\$@\""
    ) > bin/`basename $exe`
done
chmod a+x bin/*

echo "$package_id" > package_id.txt

cat <<EOF
Done!

Now, you will need to install the dependencies if you have not already
done so.  These are:

    Linux kernel>=2.6:  Required for LID support.
    Qt >= 5.7 with QtWebEngine and QtWebSockets: 
                        Cross-platform GUI library, required for the
                        IDE and for sclang's Qt GUI kit. It's best to
                        get the latest Qt 5.x version.
    JACK and libjack:   Required to play audio.
    libreadline >= 5:   Required for sclang's CLI interface.
    ncurses:            Required for sclang's CLI interface.
    git:                Required for sclang's Quarks system.

The following are probably already installed, but I mention them here
for completeness:

    ALSA:               Linux sound library, required for sclang MIDI support.
    libudev:            Device manager library, required for HID support.

On Ubuntu 18.04, the following will (probably) do this:

    apt install -y qt5-default libsndfile1 libjack0 libqt5webengine5 \\
            libqt5webenginewidgets5 libsndfile1 libreadline5 libfftw3-bin \\
            libqt5websockets5 git

This MAY also work on other versions of Ubuntu or other Debian-based
distros.

Finally, you may also want to either

- add $install_dir/bin to your PATH

- create symbolic links from all files in $install_dir/bin to a
  directory in your path.

You can always uninstall SuperCollider by deleting '$install_dir'.

EOF
