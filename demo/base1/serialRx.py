import sys
import serial
from datetime import datetime
import time
import traceback

SERIAL_PORT = '/dev/ttyUSB' + sys.argv[1]

nodelist = []
def findNode(id):
	for i in range(len(nodelist)):
		if nodelist[i]["id"] == id:
			return i
	return -1

def updateNode(id, counter, state, ts, aenergy):
	idx = findNode(id)
	if idx == -1:
		node = {"id":id, "counter":counter, "state":state, "ts1":0, "aenergy1":0, "ts2":ts, "aenergy2":aenergy}
		nodelist.append(node)
	else:
		node = nodelist[idx]
		node["counter"] = counter
		node["state"] = state
		node["ts1"] = node["ts2"]
		node["aenergy1"] = node["aenergy2"]
		node["ts2"] = ts
		node["aenergy2"] = aenergy

def calcPower(node):
	P1 = 0.259246378478
	P2 = 0#4.27707806392
	tmp = (node["aenergy2"] - node["aenergy1"]) / (node["ts2"] - node["ts1"])
	return P1 * tmp + P2

def printNode():
	for i in range(len(nodelist)):
		node = nodelist[i]
		print "%d %d %d %f," %(node["id"], node["counter"], node["state"], calcPower(node)),
	print ""

def printNode(id):
	idx = findNode(id)
	if idx == -1:
		return
	node = nodelist[idx]
	print "%s %d %f" %(str(datetime.now()).rsplit(".")[0], node["id"], calcPower(node))

def parseSerialData(data):
	ts = time.time()
	tmp = data.rsplit(" ")
	id = int(tmp[0])
	counter = int(tmp[1])
	state = int(tmp[2])
	aenergy = int(tmp[3]) * 2**16 + int(tmp[4]) * 2**8 + int(tmp[5])
	return id, counter, state, ts, aenergy

ser = serial.Serial(SERIAL_PORT, 115200, timeout=2)
while True:
	try:
		data = ser.readline()
		id, counter, state, ts, aenergy = parseSerialData(data)
		updateNode(id, counter, state, ts, aenergy)
		printNode(id)
	except KeyboardInterrupt:
		exit()
	except:
		traceback.print_exc(file=sys.stdout)
ser.close()
