#!/bin/sh
export LANG=C

# Check we're running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

usage() {
cat << USAGE
Syntax
    MFSconfig.sh -T {type} -C {Controller Address} -F {Client mount point}

    -T: Installation type: all (master+chunk) | master | chunk | client 
    -C: Cloud Controller Address (default is worked out from public interface IP)
    -F: The mounting point (folder) that use to mount moosefs 
USAGE
exit 1
}


master_install() {
	my_ip=$(/sbin/ifconfig eth1 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')

	cp /etc/mfsmaster.cfg.dist /etc/mfsmaster.cfg
	cp /etc/mfsmetalogger.cfg.dist /etc/mfsmetalogger.cfg
	cp /etc/mfsexports.cfg.dist /etc/mfsexports.cfg
	cp /var/lib/mfs/metadata.mfs.empty /var/lib/mfs/metadata.mfs

	chown -R mfs:mfs /var/lib/mfs
	
	sed -i "s/$(cat /etc/hosts|grep mfsmaster|awk '{print $0}')"//g /etc/hosts	
	echo "${my_ip} mfsmaster" >> /etc/hosts

	/usr/sbin/mfsmaster start
	/usr/sbin/mfscgiserv
}

metadata_install() {
	exit 1
}

chunk_install() {
	mknod /dev/sda b 8 0
	mknod /dev/sdb b 8 16


        mkfs -t ext4 /dev/sda << EOF
y
EOF

        mkfs -t ext4 /dev/sdb << EOF
y
EOF

	umount /dev/sda
	umount /dev/sdb

	rm -rf /mnt/hd1
	rm -rf /mnt/hd2

	mkdir -p /mnt/hd1
	mkdir -p /mnt/hd2

	mount /dev/sda /mnt/hd1
	mount /dev/sdb /mnt/hd2

	groupadd mfs
	useradd -g mfs mfs

	chown -R mfs:mfs /mnt/hd1
	chown -R mfs:mfs /mnt/hd2

	if [ -f '/etc/mfshdd.cfg' ]
	then
        	rm /etc/mfshdd.cfg
	fi

	echo "/mnt/hd1" >> /etc/mfshdd.cfg
	echo "/mnt/hd2" >> /etc/mfshdd.cfg

	cp /etc/mfsexports.cfg.dist     /etc/mfsexports.cfg
	
	sed -i "s/`cat /etc/hosts|grep mfsmaster|awk '{print $0}'`"//g /etc/hosts	
	echo "${MFSMASTER_ADDR} mfsmaster" >> /etc/hosts
	/usr/sbin/mfschunkserver start
}

client_install(){
        if [ -z ${MFSMASTER_ADDR} ]
        then
                echo 'no mfs master ip address'
                exit 0
        fi	

	if [ -d ${MOUNTING_POINT} ]
	then
		mv ${MOUNTING_POINT} ${MOUNTING_POINT}~
	fi

	mkdir -p ${MOUNTING_POINT}

	sed -i "s/`cat /etc/hosts|grep mfsmaster|awk '{print $0}'`"//g /etc/hosts
        echo "${MFSMASTER_ADDR} mfsmaster" >> /etc/hosts
	
	chown -R nova:nova ${MFSMASTER_ADDR}

	/usr/bin/mfsmount ${MOUNTING_POINT} -H mfsmaster
}


while getopts T:C:F:h opts
do
  case $opts in
    T)
        INSTALL=$(echo "${OPTARG}" | tr [A-Z] [a-z])
        case ${INSTALL} in
                all|master|metadata|chunk|client)
                ;;
        *)
                usage
                ;;
        esac
        ;;
    C)
        MFSMASTER_ADDR=${OPTARG}
        ;;
    F)
	MOUNTING_POINT=${OPTARG}
	;;
    h)
        usage
        ;;
  esac
done

case ${INSTALL} in
        all)
                MASTER_INSTALL=1
                CHUNK_INSTALL=1
                ;;
	metadata)
		METADATA_INSTALL=1
		;;
        master)
                MASTER_INSTALL=1
                ;;
        chunk)
		CHUNK_INSTALL=1
                ;;
	client)
		CLIENT_INSTALL=1
		;;
esac

if [ ! -z ${MASTER_INSTALL} ]
then
	master_install
fi

if [ ! -z ${METADATA_INSTALL} ]
then
	metadata_install
fi

if [ ! -z ${CHUNK_INSTALL} ]
then
	chunk_install
fi

if [ ! -z ${CLIENT_INSTALL} ]
then
	client_install
fi

#mkdir -p /mnt/mfs
#/usr/bin/mfsmount /mnt/mfs -H mfsmaster 


