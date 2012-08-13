from scipy import *
from pylab import *
import thread

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.gridspec as gs

import cbuf
import udprx

gs = gs.GridSpec(2, 2)
fig = plt.figure()

y = []
l = []

# Z1
ax = plt.subplot(gs[0,:])
bufsize = 2**8
ax.set_ylim(0, 2**12)
ax.set_xlim(0, bufsize)
tmpx = np.zeros(bufsize)
for j in range(bufsize):
	tmpx[j] = j
tmpy = np.zeros(bufsize+1)
tmpl, = ax.plot(tmpx, tmpy[0:bufsize])
l.append(tmpl)
y.append(tmpy)

# WU
ax = plt.subplot(gs[1,:])
bufsize = 2**7
ax.set_ylim(0, 2**10)
ax.set_xlim(0, bufsize)
tmpx = np.zeros(bufsize)
for j in range(bufsize):
	tmpx[j] = j
for i in range(2):
	tmpy = np.zeros(bufsize+1)
	tmpl, = ax.plot(tmpx, tmpy[0:bufsize])
	l.append(tmpl)
	y.append(tmpy)

def init():
	try:
		thread.start_new_thread(udprx.Z1Thread, (y[0],))
		thread.start_new_thread(udprx.PThread, (y[1],))
		thread.start_new_thread(udprx.QThread, (y[2],))
	except:
		print "Error creating thread. Exit now."
		quit

def animate(i):
	for i in range(len(y)):
		l[i].set_ydata(cbuf.cclone(y[i]))
	return 0

try:
	ani = animation.FuncAnimation(fig, animate, init_func=init, interval=100)
	plt.show()
except KeyboardInterrupt:
	quit
