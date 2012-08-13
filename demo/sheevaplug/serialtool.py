import os
import time
import serial
from datetime import datetime

cwd = "/sys/bus/usb/drivers/usb"

def scan(name, id):
	try:
		devs = os.listdir(cwd)
	except:
		print "%s not exist"%cwd
		return "none"

	for dev in devs:
		pro = "%s/%s/product"%(cwd, dev)
		ser = "%s/%s/serial"%(cwd, dev)
		try:
			product = open(pro, "r").readline().rstrip("\n")
			serial = open(ser, "r").readline().rstrip("\n")
		except:
			continue
		if product == name and serial == id:
			tmp = "%s/%s/%s:1.0"%(cwd, dev, dev)
			try:
				items = os.listdir(tmp)
			except:
				continue
			for item in items:
				if item.startswith("ttyUSB"):
					return "/dev/%s"%item
	return "none"

def detect(name, id, delay):
	while True:
		port = scan(name, id)
		if port.startswith("/dev/ttyUSB"):
			return port
		else:
			time.sleep(delay)

def connect(name, port, baud, timeout, delay):
	while True:
		try:
			ser = serial.Serial(port, baud, timeout=timeout)
			print "[%s] %s connected to %s"%(datetime.now(), name, port)
			return ser
		except:
			time.sleep(delay)

def disconnect(name, ser):
	ser.close()
	print "[%s] %s disconnected from %s"%(datetime.now(), name, ser.port)

def readCfg():
	cfg = {}
	openfile = open("cfg", "r")
	for line in openfile:
		if line == "":
			continue
		tmp = line.rstrip("\n").rsplit("=")
		try:
			cfg[tmp[0]] = tmp[1]
		except:
			pass
	return cfg
