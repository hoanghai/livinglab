import thread
import traceback
import sys
import socket
import time
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
			print line,
		except:
			pass
	return cfg

# Receive RATE data to control the *sampling* rate of WU and Z1
def Rate_UDPRx_Thread(cfg, DEBUG):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind(("", int(cfg["RATE_UDP_PORT"])))
	while True:
		data, addr = sock.recvfrom(1000)
		tmp = data.rstrip("\n").rsplit("=")
		try:
			cfg[tmp[0]] = str(int(tmp[1])) # value should be convertable to int
			if DEBUG:
				print data
		except:
			pass

# Send data to PC's training module
# This data is collected from TRAIN, WU and BS 
def Data_UDPTx_Thread(cfg, DEBUG):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	counter = 0
	while True:
		datastr = "%s,%d,%d"%(cfg["TRAIN"], counter, wu.wu["p"])
		for node in bs.nl.nodelist:
			if node["state"] == 1:
				datastr = "%s,%d"%(datastr, node["id"])
		sock.sendto(datastr, (cfg["UDP_IP"], int(cfg["DATA_UDP_PORT"])))
		counter += 1
		if DEBUG:
			print datastr
		time.sleep(1.0)

# Receive TRAIN event notification from PC
def Train_UDPRx_Thread(cfg, DEBUG):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind(("", int(cfg["TRAIN_UDP_PORT"])))
	while True:
		data, addr = sock.recvfrom(1000)
		tmp = data.rstrip("\n").rsplit("=")
		try:
			cfg[tmp[0]] = str(int(tmp[1])) # value should be convertable to int
			if DEBUG:
				print data
		except:
			pass

##################################################
#                      MAIN                      #
##################################################
cfg = readCfg()

try:
	#thread.start_new_thread(bs.BS_SerialRx_Thread, (cfg, DEBUG,))
	#thread.start_new_thread(bs.BS_UDPTx_Thread, (cfg, DEBUG, ))

	#thread.start_new_thread(wu.WU_SerialRx_Thread, (cfg, DEBUG,))
	#thread.start_new_thread(wu.WU_UDPTx_Thread, (cfg, DEBUG, ))

	thread.start_new_thread(z1.Z1Thread, (cfg, DEBUG,))

	#thread.start_new_thread(Rate_UDPRx_Thread, (cfg, True,))

	#thread.start_new_thread(Train_UDPRx_Thread, (cfg, True,))

	#thread.start_new_thread(Data_UDPTx_Thread, (cfg, True,))
except:
	traceback.print_exc(file=sys.stdout)

try:
	while(1):
		pass
except KeyboardInterrupt:
	quit()
