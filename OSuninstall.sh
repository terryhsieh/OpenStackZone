#!/bin/bash

# Really simple (and gung-ho) script to remove OpenStack
#apt-get remove nova-compute nova-network nova-api nova-objectstore keystone glance nova-scheduler
mysql -uroot -popenstack -e "drop database if exists nova;"
mysql -uroot -popenstack -e "drop database if exists glance;"
mysql -uroot -popenstack -e "drop database if exists keystone;"
#apt-get autoremove
