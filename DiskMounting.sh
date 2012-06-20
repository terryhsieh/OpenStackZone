#!/bin/bash
# The script is placed in rc.local directory and
# executes to mount /dev/sda1 /dev/sda2 and /dev/sdb
# History:
# 2012/02/03 CW First release
# 2012/02/15 Modified by CW for checking the existence of /dev/sda and /dev/sdb

#sudo /etc/init.d/glusterfs-server stop
#count=10
i=0 
#while [ "$i" != "10" ]
#do
#	i=$(($i+1))   
#	sleep 1 
#	echo "sleep $i sec to wake up device "
	
#done

mknod /dev/sda b 8 0
mknod /dev/sdb b 8 16

test -e /dev/sda
sdaTestCode=$?
test -e /dev/sdb
sdbTestCode=$?
if [ "$sdaTestCode" != 0 ]; then
	echo "Device sda does not exist!"
	exit 1
fi

# Copy the configuration of GlusterFS in RAM
# and try to mount /dev/sda1 on /etc/glusterd
#umount /dev/sda1
mkdir -p /etc/LocalDisk
mkdir -p /mnt/
#sudo cp -r /etc/glusterd /glusterdTmp
mount /dev/sda1 /etc/LocalDisk
MountCode=$?

TestCode=1
if [ "$MountCode" == 0 ]; then
	test -f /etc/LocalDisk/FirstBootDone
	TestCode=$?
fi

if [ "$MountCode" == 0 ] && [ "$TestCode" == 0 ]; then
	rm -rf /glusterdTmp
	echo "Old Configurations exist!"
else
# FirstBootDone does not exist and it means that /dev/sda1 
# is a new partition.
#	umount /dev/sda
#	umount /dev/sda1
#	umount /dev/sda2
#	umount /dev/sda3
#	umount /dev/sda4
	mkfs -t ext4 /dev/sda << EOF
y
EOF
	fdisk /dev/sda << EOF
n
p
1
1
+1G
n
p
2


w
EOF
	mkfs -t ext4 /dev/sda1 << EOF
y
EOF
	mkfs -t ext4 /dev/sda2 << EOF
y
EOF
	mount /dev/sda1 /etc/LocalDisk
	#sudo cp -r /glusterdTmp/* /etc/glusterd
	#touch /etc/LocalDisk/FirstBootDone
	# FirstBootDone is a mark for the old configurations of GlusterFS
	rm -rf /glusterdTmp
	mkfs -t ext4 /dev/sdb << EOF
y
EOF
fi

# Mount /dev/sda2 and /dev/sdb for the usage of GlusterFS
#sudo mkdir -p /GlusterHD
mkdir -p /mnt/hd1
chown -R mfs:mfs  /mnt/
mount /dev/sda2 /mnt/hd1
if [ "$sdaTestCode" == 0 ] && [ "$sdbTestCode" != 0 ]; then
	#sudo mount /dev/sda2 /GlusterHD
	mount /dev/sda2 /mnt/hd1
	echo " sdb device does not exist!"
	sleep 2
	exit 1
fi

mkdir -p /mnt/hd2
mount /dev/sdb /mnt/hd2
chown -R mfs:mfs  /mnt/
echo "/mnt/hd2" >> /etc/mfshdd.cfg
#/usr/sbin/mfschunkserver start
#mkdir -p /mnt/mfs
#/usr/bin/mfsmount /mnt/mfs -H mfsmaster 


