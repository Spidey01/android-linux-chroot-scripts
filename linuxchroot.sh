#!/system/bin/sh
#
# My custom script for chrooting into a linux chroot.
# This is run OUTSIDE the chroot by ANDROID.
#

export TERM=linux
export HOME=/root
export USER=root
export LOGNAME=root
export UID=0
unset SHELL
unset TMPDIR

# Find a busybox to use. Spaces are your problem mac'.
for busybox in \
    /data/data/com.magicandroidapps.bettertermpro/bin/busybox.exe \
    /system/xbin/busybox \
    /system/bin/busybox \
	/data/data/com.galoula.LinuxInstall/bin/busybox \
    /bin/busybox
    #FIXME and move to after galoula /data/data/com.spartacusrex.spartacuside/ 
do
    if [ -x $busybox ]; then
        export busybox
        break
    fi
done

if [ -z "$LINUX_CHROOT" ]; then
    export LINUX_CHROOT=/data/local/Linux
fi

if [ ! -d "$LINUX_CHROOT" ]; then
    echo "No chroot detected. Aborting."
    echo "Export LINUX_CHROOT or link your chroot to /data/local/Linux"
    exit 127
fi

echo "Initializing chroot..."
# sequence of busybox scripts and commands to run in a sanitary sub shell.
(
    for rc in \
        "/etc/init.android/rc.enter" \
        "/usr/local/etc/init.android/rc.enter" \
        "chroot $LINUX_CHROOT env SHELL=/bin/sh /bin/sh -i -l" \
        "/etc/init.android/rc.leave" \
        "/usr/local/etc/init.android/rc.leave"
    do
        case $rc in
            /*)
                rcfile="${LINUX_CHROOT}/${rc}"
                if [ -f "$rcfile" ]; then
                    echo "Running $rc script..."
                    echo "$busybox" "$rcfile"
                else
                    echo "No $rc script..."
                fi
                ;;
            *)
                $busybox $rc
                ;;
        esac

    done
)

