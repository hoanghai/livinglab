from scipy import *
from pylab import *
import thread

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.gridspec as gs

import cbuf
import udprx

gs = gs.GridSpec(3, 2)
fig = plt.figure()

# Z1
ax = plt.subplot(gs[0,:])
bufsize = 2**8
ax.set_ylim(0, 2**12)
ax.set_xlim(0, bufsize)

z1x = np.zeros(bufsize)
for j in range(bufsize):
	z1x[j] = j
z1y = np.zeros(bufsize+1)
z1line, = ax.plot(z1x, z1y[0:bufsize])

# P&Q
ax = plt.subplot(gs[1,:])
bufsize = 2**7
ax.set_ylim(0, 2**10)
ax.set_xlim(0, bufsize)

pqx = np.zeros(bufsize)
for j in range(bufsize):
	pqx[j] = j
py = np.zeros(bufsize+1)
qy = np.zeros(bufsize+1)
pline, qline, = ax.plot(pqx, py[0:bufsize], pqx, qy[0:bufsize])

# Ground truth
size = 5
color = ["red", "green", "blue", "cyan", "yellow"]
ax = plt.subplot(gs[2,:])
bufsize = 2**7
ax.set_ylim(0, 2**10)
ax.set_xlim(0, bufsize)

gtx = np.zeros(bufsize)
for j in range(bufsize):
	gtx[j] = j
gty = []
gtline = []
for j in range(size):
	tmpy = np.zeros(bufsize+1)
	tmpline, = ax.plot(gtx, tmpy[0:bufsize])
	gtline.append(tmpline)
	gty.append(tmpy)

def init():
	try:
		thread.start_new_thread(udprx.Z1Thread, (z1y,))
		thread.start_new_thread(udprx.PThread, (py,))
		thread.start_new_thread(udprx.QThread, (qy,))
		thread.start_new_thread(udprx.GTThread, (gty,))
	except:
		print "Error creating thread. Exit now."
		quit

def animate(i):
	z1line.set_ydata(cbuf.cclone(z1y))
	pline.set_ydata(cbuf.cclone(py))
	qline.set_ydata(cbuf.cclone(qy))

	for i in range(0, size):
		gtline[i].set_ydata(cbuf.cclone(gty[i]))
		'''
		curr = cbuf.cclone(gty[i])
		if i == 0:
			prev = 0
		else:
			prev = cbuf.cclone(gty[i-1])
		plt.subplot(gs[2,:]).fill_between(gtx, curr, prev, color=color[i])
		'''
	return 0

try:
	ani = animation.FuncAnimation(fig, animate, init_func=init, interval=100)
	plt.show()
except KeyboardInterrupt:
	quit
