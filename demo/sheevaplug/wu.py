import sys
import serial
import time
from datetime import datetime
import socket
import math
import serialtool as st

UDP_IP = "192.168.10.100"
UDP_PORT = 9000

WU_NAME = "FT232R USB UART"
WU_ID = "A1017BXB"

def parseData(data):
	tmp = data.rsplit(",")
	activep = int(tmp[3])
	apparentp = int(tmp[20])
	pf = int(tmp[16])
	reactivep = int(math.sqrt(apparentp**2 - activep**2))
	return activep, reactivep

def formatData(activep, reactivep):
	datastr = "%d %d"%(activep, reactivep)
	return datastr

def WUThread(DEBUG):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

	while True:
		wuport = st.detect(WU_NAME, WU_ID, 0.1)
		wuserial = st.connect(wuport, 115200, 2, 0.1)

		while True:
			try:
				# Receive serial
				line = wuserial.readline()
				if line == "":
					st.disconnect(wuserial)
					break

				# Parse data
				activep, reactivep = parseData(line[1:len(line)-3])
				
				# Send UDP
				datastr = formatData(activep, reactivep)
				sock.sendto(datastr, (UDP_IP, UDP_PORT))

				# Debug
				if DEBUG:
					print "%s %s"%(line, datastr)
			except KeyboardInterrupt:
				quit()
			except:
				st.disconnect(wuserial)
				break
	serialwu.close()

WUThread(True)
