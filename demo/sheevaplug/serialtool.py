import os
import time
import serial

cwd = "/sys/bus/usb/drivers/usb"

def scan(name, id):
	devs = os.listdir(cwd)
	for dev in devs:
		pro = "%s/%s/product"%(cwd, dev)
		ser = "%s/%s/serial"%(cwd, dev)

		if os.path.isfile(pro) and os.path.isfile(ser):
			product = open(pro, "r").readline().rstrip("\n")
			serial = open(ser, "r").readline().rstrip("\n")
			if product == name and serial == id:
				# This is the folder we're looking for
				# Dig deeper to find the serial port
				tmp = "%s/%s/%s:1.0"%(cwd, dev, dev)
				if not os.path.isdir(tmp):
					return "none"
				items = os.listdir(tmp)
				for item in items:
					if item.startswith("ttyUSB"):
						return "/dev/%s"%item
	return "none"

def detect(name, id, delay):
	while True:
		port = scan(name, id)
		if port.startswith("/dev/ttyUSB"):
			#print "device found at %s"%port
			return port
		else:
			#print "device not found. rescanning..."
			time.sleep(delay)

def connect(name, port, baud, timeout, delay):
	while True:
		try:
			ser = serial.Serial(port, baud, timeout=timeout)
			print "%s connected to %s"%(name, port)
			return ser
		except:
			#print "cannot connect to %s, reconnecting..."%port
			time.sleep(delay)

def disconnect(name, ser):
	ser.close()
	print "%s disconnected from %s"%(name, ser.port)
	#time.sleep(0.1)
