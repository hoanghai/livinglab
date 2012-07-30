import serial
import sys

ser = serial.Serial("/dev/ttyUSB" + sys.argv[1], 115200, timeout=2)

while True:
	try:
		data = ser.read(20)
		print data
	except KeyboardInterrupt:
		quit()
