from scipy import *
from pylab import *

import thread
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sys
import UDPRx
import cbuf

UDP_PORT = 9990
portNum = 1
try:
	UDP_PORT = int(sys.argv[1])
	portNum = int(sys.argv[2])
except:
	pass

size = 2**10
sig = np.zeros([portNum, size+1])
x = np.zeros(size)
for i in range(0, size):
	x[i] = i

fig = plt.figure()
ax = fig.add_subplot(111)
ax.set_ylim(0, 4096)
l = []
for i in range(portNum):
	tmp, = ax.plot(x, x)
	l.append(tmp)

def init():
	try:
		for i in range(portNum):
			thread.start_new_thread(UDPRx.serial_thread, ("serial", UDP_PORT+i, sig[i,:]))
	except:
		print "Error create serial thread"

def animate(i):
	for i in range(portNum):
		l[i].set_ydata(cbuf.cclone(sig[i,:]))
	return 0

ani = animation.FuncAnimation(fig, animate, sig, init_func=init, interval=100)
plt.show()
