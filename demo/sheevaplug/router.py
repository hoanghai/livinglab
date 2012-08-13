import thread
import traceback
import sys
import socket
import serialtool as st
import bs
import wu
import z1

DEBUG = False

def readCfg():
	cfg = {}
	openfile = open("cfg", "r")
	for line in openfile:
		if line == "" or line.startswith("#"):
			continue
		tmp = line.rstrip("\n").rsplit("=")
		try:
			cfg[tmp[0]] = tmp[1]
			print tmp
		except:
			pass
	return cfg

def Rate_UDPRx_Thread(cfg, DEBUG):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind(("", int(cfg["RATE_UDP_PORT"])))
	while True:
		data, addr = sock.recvfrom(1000)
		tmp = data.rstrip("\n").rsplit("=")
		try:
			cfg[tmp[0]] = str(int(tmp[1])) # value should be convertable to int
			if DEBUG:
				print tmp
		except:
			pass

####################
#       MAIN       #
####################
cfg = readCfg()

try:
	thread.start_new_thread(bs.BS_SerialRx_Thread, (cfg, DEBUG,))
	thread.start_new_thread(bs.BS_UDPTx_Thread, (cfg, DEBUG, ))

	thread.start_new_thread(wu.WU_SerialRx_Thread, (cfg, DEBUG,))
	thread.start_new_thread(wu.WU_UDPTx_Thread, (cfg, DEBUG, ))

	thread.start_new_thread(z1.Z1Thread, (cfg, DEBUG,))

	thread.start_new_thread(Rate_UDPRx_Thread, (cfg, True,))
except:
	traceback.print_exc(file=sys.stdout)

try:
	while(1):
		pass
except KeyboardInterrupt:
	quit()
