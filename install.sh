#
#
# usage: busybox sh install.sh {where to install debian chroot}
#
# LINUX_CHROOT will be used if nonthing is specified.
# You can specify what busybox will be used when needed by setting BUSYBOX to the busybox executable.
#
# /system/bin/sh can run this on my system but I can't promise it will on yours.
#

if [ -z "$BUSYBOX" ]; then
    # Find a busybox to use. Spaces are your problem mac'.
    for busybox in \
        /system/xbin/busybox \
        /system/bin/busybox \
        /data/data/com.magicandroidapps.bettertermpro/bin/busybox.exe \
        /data/data/com.galoula.LinuxInstall/bin/busybox \
        /bin/busybox
        # TODO add the one in /data/data/com.spartacusrex.spartacuside/ before galoula's
    do
        if [ -x $busybox ]; then
            export BUSYBOX="$busybox"
            break
        fi
    done
fi

if [ -n "$1" ]; then
    export LINUX_CHROOT="$1"
fi
if [ -z "$LINUX_CHROOT" ]; then
    export LINUX_CHROOT=/data/local/Linux
fi
export LINUX_CHROOT_RCDIR="${LINUX_CHROOT}/etc/init.android"

if mkdir -p "$LINUX_CHROOT" && [ ! -d "$LINUX_CHROOT" ]; then
    echo "Failed to create $LINUX_CHROOT. Aborting."
    exit 2
fi


# ugh, I hate debootstrap.
if type perl >/dev/null && [ ! -x pkgdetails ]; then
    echo "You may need to install perl or cross compile pkgdetails.c""
    echo "If one of my provided binaries work, you can do:"
    echo "     cd `pwd`"
    echo "     ln -s ./pkgdetails.ARCH ./debootstrap/pkgdetails"
    echo "And cross your fingers."
fi
export PATH="/bin:/usr/bin:/sbin:/usr/sbin:$PATH"
export HOME=/root
export TERM=linux
export DEBOOTSTRAP_DIR="`pwd`/debootstrap"
if ! busybox sh \
     ./debootstrap/debootstrap --arch=armel --foreign squeeze "$LINUX_CHROOT"
then
    echo "Failed to run initial debootstrap; *sadface*"
    exit 1
fi


