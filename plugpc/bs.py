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

nodelist = []

def updateNodeList(id, counter, state, current, activep):
	global nodelist
	# Search index
	idx = -1
	if len(nodelist) != 0:
		for i in range(len(nodelist)):
			if nodelist[i]["id"] == id:
				idx = i
				break
	# If not found then create new node
	if idx == -1:
		node = {"id": id, "counter":0, "state":0, "current":0, "activep":0}
		nodelist.append(node)
	else:
		node = nodelist[idx]
	# Update
	node["counter"] = counter
	node["state"] = state
	node["current"] = current
	node["activep"] = activep

def readBSThread(bsport, DEBUG):
	serialbs = serial.Serial(bsport, 115200, timeout=1)
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
				if DEBUG:
					print linehex
				continue

			id = int(linehex[idx+18:idx+22], 16)
			counter = int(linehex[idx+22:idx+26], 16)
			state = int(linehex[idx+26:idx+30], 16)
			current = int(linehex[idx+30:idx+36], 16)
			activep = int(linehex[idx+36:idx+42], 16)
			if DEBUG == True:
				print linehex, idx, id, counter, state, current, activep
			updateNodeList(id, counter, state, current, activep)
		except:
			print "ReadBSThread error"
			pass#traceback.print_exc(file=sys.stdout)
	serialbs.close()
