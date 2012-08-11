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
PAYLOAD_LEN = 42
MSG_LEN = HEADER_LEN + PAYLOAD_LEN
PIVOT_HEX = '4500ffff'
PIVOT_IDX = 2

nodelist = []
def findNode(id):
	for i in range(len(nodelist)):
		if nodelist[i]["id"] == id:
			return i
	return -1

def updateNode(id, counter, state, dirty, current):
	idx = findNode(id)
	if idx == -1:
		node = {"id":id, "counter":counter, "state":state, "dirty":dirty, "current": current}
		nodelist.append(node)
	else:
		node = nodelist[idx]
		node["counter"] = counter
		node["state"] = state
		node["dirty"] = dirty
		node["current"] = current

def printNode():
	for i in range(len(nodelist)):
		node = nodelist[i]
		print node["id"], node["counter"], node["state"], node["dirty"], node["current"]

def readBSThread():
	serialbs = serial.Serial('/dev/ttyUSB' + sys.argv[1], 115200, timeout=2)
	while True:
		try:
			linebin = serialbs.read(MSG_LEN)
			linehex = binascii.b2a_hex(linebin)
			idx = linehex.find(PIVOT_HEX)
			offset = (idx - PIVOT_IDX) / 2
			serialbs.read(offset % MSG_LEN)
			cond1 = linehex.startswith("7e")
			cond2 = linehex.endswith("7e")
			#print linehex, offset
			if cond1 == False or cond2 == False:
				continue

			counter1 = int(linehex[22:24], 16)
			num = int(linehex[24:26], 16)
			for i in range(num):
				offset = 26 + 14*i
				id = int(linehex[offset:offset+2], 16)
				counter = int(linehex[offset+2:offset+4], 16)
				state = int(linehex[offset+4:offset+6], 16)
				dirty = int(linehex[offset+6:offset+8], 16)
				current = int(linehex[offset+8:offset+14], 16)
				updateNode(id, counter, state, dirty, current)
			print "------\n", counter1, num
			printNode()
		except:
			pass#traceback.print_exc(file=sys.stdout)
	serialbs.close()

try:
	thread.start_new_thread(readBSThread, ())
except:
	traceback.print_exc(file=sys.stdout)

while (1):
	pass
