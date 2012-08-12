import numpy as np

def modulo_increment(val, maxVal):
	return (val + 1) % maxVal

def cwrite(buf, val):
	size = buf.size - 1
	idx = buf[size]	
	buf[idx] = val
	buf[size] = modulo_increment(idx, size)

def cclone(buf):
	newbuf = np.zeros(buf.size - 1)
	size = buf.size - 1
	idx = buf[size]
	for i in range(size):
		newbuf[i] = buf[idx]
		idx = modulo_increment(idx, size)
	return newbuf
