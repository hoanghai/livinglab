from datetime import datetime

nodelist = []

def findNode(id):
	for i in range(len(nodelist)):
		if nodelist[i]["id"] == id:
			return i
	return -1

def updateNode(id, counter, state, aenergy):
	idx = findNode(id)
	if idx == -1:
		# If not found then add new node
		node = {"id":id, "counter":counter, "state":state, "ts1":datetime.now(), "aenergy1":aenergy, "ts2":datetime.now(), "aenergy2":aenergy, "p":0}
		nodelist.append(node)
	else:
		# Update
		node = nodelist[idx]
		node["counter"] = counter
		node["state"] = state
		node["ts1"] = node["ts2"]
		node["aenergy1"] = node["aenergy2"]
		node["ts2"] = datetime.now()
		node["aenergy2"] = aenergy
		node["p"] = calcPower(node)

def calcPower(node):
	P1 = 0.259246378478
	P2 = 0#4.27707806392
	delta = node["ts2"] - node["ts1"]
	elap = delta.seconds / 1.0 + delta.microseconds / 1000000.0
	tmp = (node["aenergy2"] - node["aenergy1"]) / elap
	return max(0, P1 * tmp + P2)

def nodeToString(node):
	nodestr = "%d %d %d %f"%(node["id"], node["counter"], node["state"], node["p"])
	return nodestr

def toString():
	datastr = ""
	for node in nodelist:
		datastr = "%d %d %f, %s"%(node["id"], node["counter"], node["p"], datastr)
	return datastr
