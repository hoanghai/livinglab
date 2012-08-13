import sys
import serial
import socket
import binascii
from datetime import datetime
import serialtool as st

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
z1 = {"curr":datetime.now(), "prev":datetime.now(), "rate":0, "samples":[]}
count = 0

SIZE = 120
MSG_LEN = SIZE*2+13
START_BIN = binascii.a2b_hex('7e7e4500ffff')
def parseData(data):
	global z1
	idx = data.find(START_BIN)
	idx1 = 11+idx
	idx2 = min(MSG_LEN, 7+idx+SIZE*2)
	data = binascii.b2a_hex(data[idx1:idx2])
	length = len(data)
	i = 0

	z1["samples"] = []
	while (i + 4 < length):
		tmp = data[i+2:i+4] + data[i:i+2]
		sample = int(tmp, 16)>>2
		z1["samples"].append(sample)
		i += 4

	delta = z1["curr"] - z1["prev"]
	elap = delta.seconds / 1.0 + delta.microseconds / 1000000.0
	z1["rate"] = len(z1["samples"]) / elap

	return idx

def sendData(cfg):
	global sock, z1, count
	div = int(cfg["Z1_RATE_DIV"])
	if div != 0:
		datastr = "%s | %f |"%(z1["curr"], z1["rate"])
		for sample in z1["samples"]:
			count  = (count + 1) % div
			if count == 0:
				datastr = "%s %d"%(datastr, sample)

		sock.sendto(datastr, (cfg["UDP_IP"], int(cfg["Z1_UDP_PORT"])))

def Z1Thread(cfg, DEBUG):
	global z1
	while True:
		serport = st.detect(cfg["Z1_NAME"], cfg["Z1_ID"], 0.1)
		ser = st.connect(cfg["Z1_ALIAS"], serport, 115200, 0.1, 0.1)
		
		while True:
			try:
				line = ser.read(MSG_LEN)
				if line == "":
					st.disconnect(cfg["Z1_ALIAS"], ser)
					break
				z1["prev"] = z1["curr"]
				z1["curr"] = datetime.now()
				idx = parseData(line)
				ser.read(idx)
				sendData(cfg)
				if DEBUG:
					print datastr
			except KeyboardInterrupt:
				quit()
			except:
				st.disconnect(cfg["Z1_ALIAS"], ser)
				break
