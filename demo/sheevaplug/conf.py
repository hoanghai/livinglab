def read(config):
	openfile = open("conf", "r")
	for line in openfile:
		if line == "":
			continue
		tmp = line.rstrip("\n").rsplit("=")
		try:
			config[tmp[0]] = tmp[1]
		except:
			pass
	print config
