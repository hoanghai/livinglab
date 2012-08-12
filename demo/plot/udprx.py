import socket
import cbuf

UDP_IP = ""
WU_UDP_PORT = 9000
Z1_UDP_PORT = 9001

def Z1Thread(control, buf):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind((UDP_IP, Z1_UDP_PORT))
	suppcount = 0
	while True:
		try:
			datastr, addr = sock.recvfrom(10000)
			tmp = datastr.rsplit("|")
			data = tmp[2].rsplit(" ")
			for val in data:
				try:
					sample = int(val)
				except:
					pass

				if control["supp"] != 0:
					suppcount += 1
					if suppcount % control["supp"] == 0:
						cbuf.cwrite(buf, sample)
						suppcount = 0
		except:
			pass

def WUThread(control, buf0, buf1):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind((UDP_IP, WU_UDP_PORT))
	pcount = 0
	qcount = 0
	while True:
		try:
			datastr, addr = sock.recvfrom(10000)
			data = datastr.rsplit(" ")
			if control["p"] != 0:
				pcount += 1
				if pcount % control["p"] == 0:
					cbuf.cwrite(buf0, int(data[0]))
					pcount = 0

			if control["q"] != 0:
				qcount += 1
				if qcount % control["q"] == 0:
					cbuf.cwrite(buf1, int(data[1]))
					qcount = 0
		except:
			pass

