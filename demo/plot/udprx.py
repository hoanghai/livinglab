import socket
import cbuf

P_UDP_PORT = 9000
Q_UDP_PORT = 9001
Z1_UDP_PORT = 9003
BS_UDP_PORT = 9002
M_UDP_PORT = 9015

def Z1Thread(buf):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind(("", Z1_UDP_PORT))
	while True:
		try:
			datastr, addr = sock.recvfrom(10000)
			tmp = datastr.rsplit("|")
			data = tmp[2].rsplit(" ")
			for val in data:
				try:
					cbuf.cwrite(buf, int(val))
				except:
					pass
		except:
			pass

def PThread(buf):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind(("", P_UDP_PORT))
	while True:
		try:
			datastr, addr = sock.recvfrom(100)
			data = datastr.rstrip("\n")
			cbuf.cwrite(buf, int(data) / 10.0)
		except:
			pass

def QThread(buf):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind(("", Q_UDP_PORT))
	while True:
		try:
			datastr, addr = sock.recvfrom(100)
			data = datastr.rstrip("\n")
			cbuf.cwrite(buf, int(data) / 10.0)
		except:
			pass

def MThread(buf):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind(("", M_UDP_PORT))
	while True:
		try:
			datastr, addr = sock.recvfrom(100)
			data = datastr.rstrip("\n")
			cbuf.cwrite(buf, int(data))
		except:
			pass

def GTThread(buf):
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	sock.bind(("", BS_UDP_PORT))
	while True:
		try:
			datastr, addr = sock.recvfrom(10000)
			data = datastr.strip().rsplit(",")
			val = []
			for i in range(len(buf)):
				try:
					tmp = data[i].strip().rsplit(" ")
					val.append(float(tmp[2]))
				except:
					val.append(0)
				cbuf.cwrite(buf[i], sum(val))
		except:
			pass
