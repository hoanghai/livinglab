import sys
sys.path.append("/home/hoanghai/adsc/demo/sheevaplug/")
import serial
import socket
import serialtool as st

UDP_IP = "127.0.0.1"
UDP_PORT = 9015
MO_NAME = "Zolertia Z1"
MO_ID = "Z1RC1816"
MO_ALIAS = "MOTION"

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True:
	serport = st.detect(MO_NAME, MO_ID, 0.1)
	ser = st.connect(MO_ALIAS, serport, 115200, 2, 0.1)

	while True:
		try:
			line = ser.readline().rstrip("\n")
			if line == "":
				st.disconnect(MO_ALIAS, ser)
				break
			sock.sendto(line, (UDP_IP, UDP_PORT))
			print line
		except KeyboardInterrupt:
			quit()
		except:
			st.disconnect(MO_ALIAS, ser)
			break
