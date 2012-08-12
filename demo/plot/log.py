import socket

UDP_IP = ""
WU_UDP_PORT = 9000
Z1_UDP_PORT = 9001


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, Z1_UDP_PORT))

while True:
	datastr, addr = sock.recvfrom(10000)
	tmp = datastr.rsplit("|")
	data = tmp[2].rsplit(" ")
	for val in data:
		try:
			sample = int(val)
			print tmp[1], sample
		except:
			pass
