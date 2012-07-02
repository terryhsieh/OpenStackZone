
#set upstart config to make each service do not start at machine boot up 
for i in nova-api.conf nova-cert.conf nova-compute.conf nova-consoleauth.conf nova-console.conf nova-network.conf nova-objectstore.conf nova-scheduler.conf
do
	sed -i "s/^start on (filesystem and net-device-up IFACE!=lo)/#start on (filesystem and net-device-up IFACE!=lo)/g" /etc/init/$i
done

for i in keystone.conf glance-api.conf glance-registry.conf
do
        sed -i "s/^start on (local-filesystems and net-device-up IFACE!=lo)/#start on (local-filesystems and net-device-up IFACE!=lo)/g" /etc/init/$i
done

#because PDCM make all module into kernel, so we need to disable modprobe commant
for j in nova-compute.conf
do
	sed -i "s/^\tmodprobe nbd/\t#modprobe nbd/g" /etc/init/$j
done


for k in mysql.conf
do
	sed -i "s/^start on runlevel \[2345\]/#start on runlevel \[2345\]/g" /etc/init/$k
done

#make service that using traditional init start procedule do not start at machine boot up 
for m in rc2.d rc3.d rc4.d rc5.d
do
	for n in S20memcached S20novnc S20rabbitmq-server S91apache2 S23ntp
	do
		if [ -f /etc/$m/$n ]
		then
			unlink /etc/$m/$n
		fi
	done
done

#   make StrictHostKeyChecking ask to no
sed -i "s/^#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config
