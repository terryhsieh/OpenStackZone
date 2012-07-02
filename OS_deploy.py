from fabric.api import run,env

env.hosts = ['TPE1AA0115','TPE1AA0121','TPE1AA0122']
def check_connection():
	run("service ssh status")

def 
