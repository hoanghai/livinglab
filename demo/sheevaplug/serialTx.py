import serial
import sys

ser = serial.Serial("/dev/ttyUSB" + sys.argv[1], 115200, timeout=2)
input = sys.argv[2]

if input == "reset":
	input = "V,W,0"
elif input == "log":
	input = "L,W,3,E,,1"
serialmsg = "#%s;"%input
ser.write(serialmsg)
print serialmsg
