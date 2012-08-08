import sys
import traceback
from datetime import datetime
import time
import thread
import socket
import bs
import wu

DEBUG = 0

def sendUDPThread():
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	while True:
		datastr = "%d,%d,%d"%(bs.training, bs.counter, wu.activep)
		for i in range(len(bs.onlist)):
			datastr = "%s,%d"%(datastr, bs.onlist[i])
		print datastr
		sock.sendto(datastr, ("191.168.0.163", 8000))
		time.sleep(1)

try:
	thread.start_new_thread(bs.readBSThread, ())
	thread.start_new_thread(wu.readWUThread, ("/dev/ttyUSB" + sys.argv[1], DEBUG, ))
	thread.start_new_thread(sendUDPThread, ())
except:
	traceback.print_exc(file=sys.stdout)

try:
	while (1):
		pass
except KeyboardInterrupt:
	quit()
