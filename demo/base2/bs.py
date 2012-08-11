import socket
import sys
from datetime import datetime
import traceback
import thread

UDP_IP = ""
UDP_PORT = 9000

training = 2
counter = 0
onlist = []

def readBSThread():
	global training, counter, onlist
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind((UDP_IP, UDP_PORT))

	while True:
		try:
			data, addr = sock.recvfrom(1000)
			data = data.rstrip("\n")
			tmp = data.rsplit(",")
			training = int(tmp[0])
			counter = int(tmp[1])
			onlist = []
			for i in range(2, len(tmp)):
				onlist.append(int(tmp[i]))
		except:
			pass
