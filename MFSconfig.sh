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
    MFSconfig.sh -T {type} -C {Controller Address} 

    -T: Installation type: all (master+chunk) | master | chunk 
    -C: Cloud Controller Address (default is worked out from public interface IP)
USAGE
exit 1
}


master_install() {

}

metadata_install() {

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
	
	echo "${MFSMASTER_ADDR} mfsmaster >> /etc/hosts"
	
	/usr/sbin/mfschunkserver start
}


while getopts T:C opts
do
  case $opts in
    T)
        INSTALL=$(echo "${OPTARG}" | tr [A-Z] [a-z])
        case ${INSTALL} in
                all|master|metadata|chunk)
                ;;
        *)
                usage
                ;;
        esac
        ;;
    C)
        MFSMASTER_ADDR=${OPTARG}
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



mknod /dev/sda b 8 0
mknod /dev/sdb b 8 16


	mkfs -t ext4 /dev/sda << EOF
y
EOF

	mkfs -t ext4 /dev/sdb << EOF
y
EOF

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

cp /etc/mfsmaster.cfg.dist	/etc/mfsmaster.cfg
cp /etc/mfsmetalogger.cfg.dist	/etc/mfsmetalogger.cfg
cp /etc/mfsexports.cfg.dist	/etcmfsexports.cfg

/usr/sbin/mfschunkserver start

#mkdir -p /mnt/mfs
#/usr/bin/mfsmount /mnt/mfs -H mfsmaster 


