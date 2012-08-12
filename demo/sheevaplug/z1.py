import sys
import serial
import socket
import binascii
from datetime import datetime
import serialtool as st

UDP_IP = "192.168.10.100"
UDP_PORT = 9001

Z1_NAME = "Zolertia Z1"
Z1_ID = "Z1RC1805"

SIZE = 120
MSG_LEN = SIZE*2+13
START_BIN = binascii.a2b_hex('7e7e4500ffff')

curr = datetime.now()
prev = curr

def parseData(data):
	idx = data.find(START_BIN)
	idx1 = 11+idx
	idx2 = min(MSG_LEN, 7+idx+SIZE*2)
	data = binascii.b2a_hex(data[idx1:idx2])
	length = len(data)
	i = 0

	samples = []
	while (i + 4 < length):
		tmp = data[i+2:i+4] + data[i:i+2]
		sample = int(tmp, 16)>>2
		samples.append(sample)
		i += 4

	return idx, samples

def formatData(samples):
	global prev, curr
	delta = curr - prev
	elap = delta.seconds / 1.0 + delta.microseconds / 1000000.0
	samplingRate = len(samples) / elap
	datastr = "%s | %f |"%(curr, samplingRate)
	for sample in samples:
		datastr = "%s %d"%(datastr, sample)
	return datastr

def Z1Thread(DEBUG):
	global prev, curr
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

	while True:
		z1port = st.detect(Z1_NAME, Z1_ID, 0.1)
		z1serial = st.connect(z1port, 115200, 0.1, 0.1)
		
		while True:
			try:
				# Receive serial
				line = z1serial.read(MSG_LEN)
				if line == "":
					st.disconnect(z1serial)
					break
				curr = datetime.now()
					
				# Parse data and reallign
				idx, samples = parseData(line)
				z1serial.read(idx)

				# Send UDP
				datastr = formatData(samples)
				sock.sendto(datastr, (UDP_IP, UDP_PORT))

				# Debug
				if DEBUG:
					print datastr
				prev = curr
			except KeyboardInterrupt:
				quit()
			except:
				st.disconnect(z1serial)
				break
		
Z1Thread(True)
