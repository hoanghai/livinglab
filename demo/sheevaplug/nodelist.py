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

def nodeToString(node):
	nodestr = "%d %d %d %f"%(node["id"], node["counter"], node["state"], calcPower(node))
	return nodestr

def toString():
	datastr = "%s"%datetime.now()
	for node in nodelist:
		nodestr = nodeToString(node)
		datastr = "%s | %s"%(datastr, nodestr)
	return datastr
