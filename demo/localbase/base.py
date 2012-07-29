import sys
import serial
import traceback
from datetime import datetime
import time
import os
import binascii
import thread
import socket

HEADER_LEN = 13
PAYLOAD_LEN = 12
MSG_LEN = HEADER_LEN + PAYLOAD_LEN
PIVOT_HEX = '4500ffff'
PIVOT_IDX = 2

conf = {"wuport":"2", "bsport":"0", "udpip":"localhost", "udpport":"8000"}
def readConf():
	openfile = open("conf", "r")
	for line in openfile:
		tmp = line.rstrip("\n").split(":")
		try:
			conf[tmp[0]] = tmp[1]
		except:
			pass
	print conf

nodelist = []
current = 0

def findNode(id):
	global nodelist
	if len(nodelist) == 0:
		return -1
	for i in range(len(nodelist)):
		if nodelist[i]["id"] == id:
			return i
	return -1

def updateNodeList(id, counter, state, current, activep):
	global nodelist
	idx = findNode(id)
	if idx == -1:
		node = {"id": id, "counter":0, "state":0, "current":0, "activep":0}
		nodelist.append(node)
	else:
		node = nodelist[idx]
	node["counter"] = counter
	node["state"] = state
	node["current"] = current
	node["activep"] = activep

def sendUDPThread():
	global nodelist, current
	while True:
		ts = "%s"%datetime.now()
		datastr = "%s,%s"%(ts.split(".")[0], current)
		for node in nodelist:
			if node["state"] == 1:
				datastr = "%s,%s"%(datastr, str(node["id"]))
		sock.sendto(datastr, (conf["udpip"], int(conf["udpport"])))
		print datastr
		time.sleep(1)

def readBSThread():
	while True:
		try:
			linebin = serialbs.read(MSG_LEN)
			linehex = binascii.b2a_hex(linebin)
			idx = linehex.find(PIVOT_HEX)
			offset = (idx - PIVOT_IDX) / 2
			serialbs.read(offset % MSG_LEN)
			cond1 = linehex.startswith("7e")
			cond2 = linehex.endswith("7e")
			if cond1 == False or cond2 == False:
				continue

			id = int(linehex[idx+18:idx+22], 16)
			counter = int(linehex[idx+22:idx+26], 16)
			state = int(linehex[idx+26:idx+30], 16)
			current = int(linehex[idx+30:idx+36], 16)
			activep = int(linehex[idx+36:idx+42], 16)
			print linehex, idx, id, counter, state, current, activep
			updateNodeList(id, counter, state, current, activep)
		except:
			pass#traceback.print_exc(file=sys.stdout)
	serialbs.close()

def readWUThread():
	global current
	while True:
		try:	
			line = serialwu.readline()
			tmp = line.rsplit(",")
			current = int(tmp[3])
			print line, p
		except:
			pass#traceback.print_exc(file=sys.stdout)
	serialwu.close()

readConf()

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

try:
	serialbs = serial.Serial('/dev/ttyUSB' + conf["bsport"], 115200, timeout=1)
	thread.start_new_thread(readBSThread, ())
	#serialwu = serial.Serial('/dev/ttyUSB' + conf["wuport"], 115200, timeout=2)

	#thread.start_new_thread(readWUThread, ())
	thread.start_new_thread(sendUDPThread, ())
except:
	traceback.print_exc(file=sys.stdout)

while (1):
	pass
