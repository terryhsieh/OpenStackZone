from fabric.api import run,env

env.hosts = ['192.168.11.15', '192.168.11.21','192.168.11.22']
def check_connection():
	run("service ssh status")

