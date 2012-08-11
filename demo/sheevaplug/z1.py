import sys
import serial
import socket
import binascii
from datetime import datetime
import traceback
import thread
import time
import serialtool as st

size = 120
msglen = size*2+13
starthex = '7e7e4500ffff'
startbin = binascii.a2b_hex(starthex)

def readZ1Thread(DEBUG):
	while True:
		z1port = st.detect("Zolertia Z1", "Z1RC1805", 0.5)
		z1serial = st.connect(z1port, 115200, 0.5, 0.5)
		
		while True:
			try:	
				line = z1serial.read(msglen)
				if line == "":
					st.disconnect(z1serial)
					break
				idx = line.find(startbin)
				idx1 = 11+idx
				idx2 = min(msglen, 7+idx+size*2)
				z1serial.read(idx)
				if DEBUG:
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
				quit()
			except:
				st.disconnect(z1serial)
				break
		
readZ1Thread(True)
