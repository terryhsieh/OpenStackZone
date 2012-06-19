#!/bin/bash

# Check we're running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

CURRENT_WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEBS_TAR_NAME='essex-debs.tar.gz'
DEBS_UNTAR_FOLDER_NAME='essex-debs'
DEBS_WORKING_PATH="$( cd $CURRENT_WORKING_DIR ; cd .. ;pwd)"


if [ ! -f ${DEBS_WORKING_PATH}/${DEBS_TAR_NAME} ]
then
	wget -O ${DEBS_WORKING_PATH}/${DEBS_TAR_NAME} https://dl.dropbox.com/u/6762092/${DEBS_TAR_NAME} 
fi

if [ ! -d ${DEBS_WORKING_PATH}/${DEBS_UNTAR_FOLDER_NAME} ]
then
	cd ${DEBS_WORKING_PATH}
	echo "Extracting "${DEBS_TAR_NAME}""
	tar -zxf ${DEBS_TAR_NAME}
fi

if [ ! -f '/etc/apt/sources.list.ori' ]
then
	mv /etc/apt/sources.list /etc/apt/sources.list.ori
fi

echo "deb file:"${DEBS_WORKING_PATH}/${DEBS_UNTAR_FOLDER_NAME} ./"" > /etc/apt/sources.list

apt-get update
