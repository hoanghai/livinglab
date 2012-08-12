from datetime import datetime

nodelist = []

def findNode(id):
	for i in range(len(nodelist)):
		if nodelist[i]["id"] == id:
			return i
	return -1

def updateNode(id, counter, state, ts, aenergy):
	idx = findNode(id)
	if idx == -1:
		# If not found then add new node
		node = {"id":id, "counter":counter, "state":state, "ts1":0, "aenergy1":0, "ts2":ts, "aenergy2":aenergy}
		nodelist.append(node)
	else:
		# Update
		node = nodelist[idx]
		node["counter"] = counter
		node["state"] = state
		node["ts1"] = node["ts2"]
		node["aenergy1"] = node["aenergy2"]
		node["ts2"] = ts
		node["aenergy2"] = aenergy

def calcPower(node):
	P1 = 0.259246378478
	P2 = 4.27707806392
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

def toString():
	datastr = "%s | %d"%(datetime.now(), len(nodelist))
	for node in nodelist:
		datastr = "%s | %d %d %d"%(datastr, node["id"], node["counter"], node["state"])
	return datastr
