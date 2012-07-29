import sys
import serial
import traceback
from datetime import datetime
import time
import os
import binascii
import thread

ser = serial.Serial('/dev/ttyUSB' + sys.argv[1], 115200, timeout=2)

HEADER_LEN = 13
PAYLOAD_LEN = 12
MSG_LEN = HEADER_LEN + PAYLOAD_LEN
PIVOT_HEX = '4500ffff'
PIVOT_IDX = 2
offset = 0

nodelist = []
def findNode(id):
	global nodelist
	if len(nodelist) == 0:
		return -1
	for i in range(len(nodelist)):
		if nodelist[i]["id"] == id:
			return i
	return -1

def updateNode(id, counter, state, current, activep):
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

def printNode():
	global nodelist
	for node in nodelist:
		print node["id"], node["counter"], node["state"], node["activep"], "|",
	print ""

def printNodeThread():
	while True:
		printNode()
		time.sleep(1)

def readSerialThread():
	while True:
		try:
			linebin = ser.read(MSG_LEN)
			linehex = binascii.b2a_hex(linebin)
			idx = linehex.find(PIVOT_HEX)
			offset = (idx - PIVOT_IDX) / 2
			ser.read(offset % MSG_LEN)
			if linehex.startswith("7e") == False or linehex.endswith("7e") == False:
				continue

			id = int(linehex[idx+18:idx+22], 16)
			counter = int(linehex[idx+22:idx+26], 16)
			state = int(linehex[idx+26:idx+30], 16)
			current = int(linehex[idx+30:idx+36], 16)
			activep = int(linehex[idx+36:idx+42], 16)
			#print linehex, idx, id, counter, state, current, activep
			updateNode(id, counter, state, current, activep)
			#printNode()
		except KeyboardInterrupt:
			exit()
		except:
			pass#traceback.print_exc(file=sys.stdout)
	ser.close()

try:
	thread.start_new_thread(readSerialThread, ())
	thread.start_new_thread(printNodeThread, ())
except:
	traceback.print_exc(file=sys.stdout)

while (1):
	pass
