import sys
import serial
import socket
import time
import serialtool as st
import nodelist as nl

def parseData(data):
	tmp = data.rsplit(" ")
	id = int(tmp[0])
	counter = int(tmp[1])
	state = int(tmp[2])
	aenergy = int(tmp[3]) * 2**16 + int(tmp[4]) * 2**8 + int(tmp[5])
	nl.updateNode(id, counter, state, aenergy)

def BS_UDPTx_Thread(cfg, DEBUG):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	while True:
		datastr = nl.toString()
		sock.sendto(datastr, (cfg["UDP_IP"], int(cfg["BS_UDP_PORT"])))
		if DEBUG:
			print datastr
		time.sleep(1.0)

def BS_SerialRx_Thread(cfg, DEBUG):
	while True:
		serport = st.detect(cfg["BS_NAME"], cfg["BS_ID"], 0.1)
		ser = st.connect(cfg["BS_ALIAS"], serport, 115200, 2, 0.1)

		while True:
			try:
				line = ser.readline()
				if line == "":
					st.disconnect(cfg["BS_ALIAS"], ser)
					break
				parseData(line)
				if DEBUG:
					print datastr
			except KeyboardInterrupt:
				quit()
			except:
				st.disconnect(cfg["BS_ALIAS"], ser)
				break
