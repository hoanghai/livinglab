import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("", 9012))
while True:
	data, addr = sock.recvfrom(1000)
	print data
	sock.sendto(data, ("192.168.0.163", 8000))
