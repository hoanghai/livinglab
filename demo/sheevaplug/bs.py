import sys
import serial
import time
import socket
import serialtool as st
import nodelist as nl

UDP_IP = "192.168.10.100"
UDP_PORT = 9002

BS_NAME = "Zolertia Z1"
BS_ID = "Z1RC1833"

def parseData(data):
	ts = time.time()
	tmp = data.rsplit(" ")
	id = int(tmp[0])
	counter = int(tmp[1])
	state = int(tmp[2])
	aenergy = int(tmp[3]) * 2**16 + int(tmp[4]) * 2**8 + int(tmp[5])
	return id, counter, state, ts, aenergy

def BSThread(DEBUG):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

	while True:
		bsport = st.detect(BS_NAME, BS_ID, 0.1)
		bsserial = st.connect("BS", bsport, 115200, 2, 0.1)

		while True:
			try:
				# Receive serial
				line = bsserial.readline()
				if line == "":
					st.disconnect("BS", bsserial)
					break

				# Parse and update data
				id, counter, state, ts, aenergy = parseData(line)
				nl.updateNode(id, counter, state, ts, aenergy)

				# Send UDP
				datastr = nl.toString()
				sock.sendto(datastr, (UDP_IP, UDP_PORT))

				# Debug
				if DEBUG:
					print datastr
			except KeyboardInterrupt:
				quit()
			except:
				st.disconnect("BS", bsserial)
				break

#BSThread(True)
