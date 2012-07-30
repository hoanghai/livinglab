import sys
import traceback
from datetime import datetime
import time
import thread
import socket
import bs
import wu

DEBUG = 0

conf = {"wuport":"2", "bsport":"0", "udpip":"localhost", "udpport":"8000"}
def readConf():
	openfile = open("conf", "r")
	for line in openfile:
		tmp = line.rstrip("\n").split(":")
		try:
			conf[tmp[0]] = tmp[1]
		except:
			pass
	print conf

def sendUDPThread():
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	while True:
		ts = "%s"%datetime.now()
		datastr = "%s,%s"%(ts.split(".")[0], wu.activep)
		for node in bs.nodelist:
			if node["state"] == 1:
				datastr = "%s,%s"%(datastr, str(node["id"]))
		sock.sendto(datastr, (conf["udpip"], int(conf["udpport"])))
		print datastr
		time.sleep(1)

readConf()
try:
	DEBUG = sys.argv[1] == "1"
except:
	pass

try:
	thread.start_new_thread(bs.readBSThread, (conf["bsport"], DEBUG, ))
	thread.start_new_thread(wu.readWUThread, (conf["wuport"], DEBUG, ))
	thread.start_new_thread(sendUDPThread, ())
except:
	traceback.print_exc(file=sys.stdout)

try:
	while (1):
		pass
except KeyboardInterrupt:
	quit()
