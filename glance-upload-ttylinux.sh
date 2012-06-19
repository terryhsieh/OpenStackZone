ADMIN='admin'
PASSWORD='openstack'
TENANT='demo'
ENDPOINT='192.168.220.100'

cd ..

if [ ! -f "ttylinux-uec-amd64-12.1_2.6.35-22_1.tar.gz" ] ; then
	echo "Downloading image"
	wget http://smoser.brickies.net/ubuntu/ttylinux-uec/ttylinux-uec-amd64-12.1_2.6.35-22_1.tar.gz
fi

if [ ! -f "ttylinux-uec-amd64-12.1_2.6.35-22_1.img" ] ; then
        echo "Extracting image"
	tar xfzv ttylinux-uec-amd64-12.1_2.6.35-22_1.tar.gz 
fi

echo "Uploading kernel"
RVAL=`glance -I ${ADMIN} -K ${PASSWORD} -T ${TENANT} -N http://${ENDPOINT}:5000/v2.0 add name="ttylinux-kernel" is_public=true container_format=aki disk_format=aki < ttylinux-uec-amd64-12.1_2.6.35-22_1-vmlinuz`
KERNEL_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`

echo "Uploading ramdisk"
RVAL=`glance -I ${ADMIN} -K ${PASSWORD} -T ${TENANT} -N http://${ENDPOINT}:5000/v2.0 add name="ttylinux-ramdisk" is_public=true container_format=ari disk_format=ari < ttylinux-uec-amd64-12.1_2.6.35-22_1-initrd`
RAMDISK_ID=`echo $RVAL | cut -d":" -f2 | tr -d " "`

echo "Uploading image"
glance -I ${ADMIN} -K ${PASSWORD} -T ${TENANT} -N http://${ENDPOINT}:5000/v2.0 add name="ttylinux" is_public=true container_format=ami disk_format=ami kernel_id=$KERNEL_ID ramdisk_id=$RAMDISK_ID < ttylinux-uec-amd64-12.1_2.6.35-22_1.img
