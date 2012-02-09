#!/system/bin/sh
#
# My custom script for chrooting into a linux chroot.
# This is run OUTSIDE the chroot by ANDROID.
# You must be root.
#

# this is stuff for init scripts, login will sanitize the shell session.
export PATH="/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
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
        export BUSYBOX
        break
    fi
done

if [ -z "$LINUX_CHROOT" ]; then
    export LINUX_CHROOT=/data/local/Linux
fi
export LINUX_CHROOT_RCDIR="${LINUX_CHROOT}/etc/init.android"

if [ ! -d "$LINUX_CHROOT" ]; then
    echo "No chroot detected. Aborting."
    echo "Export LINUX_CHROOT or link your chroot to /data/local/Linux"
    exit 127
fi
if [ ! -d "$LINUX_CHROOT_RCDIR" ]; then
    echo "Can't find chroot init scripts. Aborting."
    exit 127
fi

echo "Initializing chroot..."
# sequence of busybox scripts and commands to run in a sanitary sub shell.
(
    if ! cd "$LINUX_CHROOT"; then
        echo "Can't cd to chroot"
        return 1
    fi

    # Source rc.conf files NOW.
    for conf in \
        etc/init.android/rc.conf \
        usr/local/etc/init.android/rc.conf
    do
        if [ -f "$conf" ]; then
            . "./$conf"
            export `cat "$conf" | \
                        grep -v -E '^\s*#' | grep -v -E '^$' | \
                        cut -d= -f 1` >/dev/null
        fi
    done

    for rc in \
        "/etc/init.android/rc.enter" \
        "/usr/local/etc/init.android/rc.enter" \
        "chroot $LINUX_CHROOT /bin/login -f root" \
        "/etc/init.android/rc.leave" \
        "/usr/local/etc/init.android/rc.leave"
    do
        case $rc in
            /*)
                rcfile="${LINUX_CHROOT}/${rc}"
                if [ -f "$rcfile" ]; then
                    echo "Running $rc script..."
                    if ! $BUSYBOX sh $rcfile; then
                        echo "$rc script failed. Aborting chroot entry."
                        exit 1
                    fi
                else
                    echo "No $rc script..."
                fi
                ;;
            *)
                if ! $BUSYBOX $rc; then
                    echo "Bad busybox command. Aborting chroot entry."
                    exit 1
                fi
                ;;
        esac

    done
)

