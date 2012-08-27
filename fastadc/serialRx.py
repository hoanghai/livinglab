import sys
import serial
import socket
import numpy as np
import binascii
from datetime import datetime
import traceback
import thread
import time

SERIAL_PORT = '0'
UDP_IP="127.0.0.1"
UDP_PORT=9999
try:
	SERIAL_PORT = sys.argv[1]
	UDP_PORT = int(sys.argv[2])
except:
	pass

sock = socket.socket( socket.AF_INET, socket.SOCK_DGRAM )

ser = serial.Serial('/dev/ttyUSB' + SERIAL_PORT, 115200, timeout=1)

size = 120
msglen = size*2+13
starthex = '7e7e4500ffff'
startbin = binascii.a2b_hex(starthex)
count = 0
start = time.time()
end = start

while True:
	try:	
		line = ser.read(msglen)
		end = time.time()
		count += 1

		idx = line.find(startbin)
		idx1 = 11+idx
		idx2 = min(msglen, 7+idx+size*2)
		sock.sendto(line[idx1:idx2], (UDP_IP, UDP_PORT))
		ser.read(idx)

		print count, count/(end-start), size*count/(end-start), idx, time.time()

		x = binascii.b2a_hex(line[idx1:idx2])
		length = len(x)
		i = 0
		while (i + 4 < length):
			tmp = x[i+2:i+4] + x[i:i+2]
			val = int(tmp, 16)>>2
			print val,
			i += 4
		print ''
	except KeyboardInterrupt:
		exit()
	except:
		traceback.print_exc(file=sys.stdout)
ser.close()
