import binascii
import socket
import datetime
import cbuf
import struct
import numpy as np

UDP_IP= ""

def serial_thread(threadNam, port, buf):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind((UDP_IP, port))
	print threadNam + ' started'
	temp = True
	while temp:
		data, addr = sock.recvfrom(10000)
		x = binascii.b2a_hex(data)
		length = len(x)
		i = 0
		while (i + 4 < length):
			tmp = x[i+2:i+4] + x[i:i+2]
			val = int(tmp, 16)>>2
			cbuf.cwrite(buf, val)
			i += 4
