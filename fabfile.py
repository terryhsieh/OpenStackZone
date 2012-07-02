from fabric.api import *

env.roledefs = {
    'controller': ['management'],
    'node': ['node1','node2','node3'],
    'all':['management','node1','node2','node3']
}

@roles('all')
def check_sshd():
	run('service ssh status')

@roles('controller')
def install_controller():
	with cd('OpenStackZone'):
		run('./MFSconfig.sh -T master')
		run('./OSconfig.sh -F 172.16.0.0/24')

@roles('all')
def install_compute():
	with cd('OpenStackZone'):
		run('./MFSconfig.sh -T chunk -C 192.168.220.100')
		run('./MFSconfig.sh -T client -C 192.168.220.100')
		run('./OSconfig.sh -T compute -C 192.168.220.100')
