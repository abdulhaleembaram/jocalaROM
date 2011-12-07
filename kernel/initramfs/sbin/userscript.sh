#!/system/bin/sh
# Remount filesystems RW
busybox mount -o remount,rw / /
busybox mount -o remount,rw /system /system

# Enable init.d support
if [ -d /system/etc/init.d ]
then
	logwrapper busybox run-parts /system/etc/init.d
fi
sync

# Fix screwy ownerships
for blip in conf default.prop fota.rc init init.goldfish.rc init.rc init.smdkc110.rc lib lpm.rc modules recovery.rc res sbin bin
do
	chown root.shell /$blip
	chown root.shell /$blip/*
done

chown root.shell /lib/modules/*
chown root.shell /res/images/*

#setup proper passwd and group files for 3rd party root access
# Thanks DevinXtreme
if [ ! -f "/system/etc/passwd" ]; then
	echo "root::0:0:root:/data/local:/system/bin/sh" > /system/etc/passwd
	chmod 0666 /system/etc/passwd
fi
if [ ! -f "/system/etc/group" ]; then
	echo "root::0:" > /system/etc/group
	chmod 0666 /system/etc/group
fi

# fix busybox DNS while system is read-write
if [ ! -f "/system/etc/resolv.conf" ]; then
	echo "nameserver 8.8.8.8" >> /system/etc/resolv.conf
	echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
fi
sync
if [ -f "/system/media/bootanimation.zip" ]; then
ln -s /system/media/bootanimation.zip /system/media/sanim.zip
fi

# remount read only and continue
busybox  mount -o remount,ro / /
busybox  mount -o remount,ro /system /system
