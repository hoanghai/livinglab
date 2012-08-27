from scipy import *
from pylab import *
import thread

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.gridspec as gridspec
import random

import cbuf
import udprx

fig = plt.figure()
fig.canvas.set_window_title("Results")
fig.subplots_adjust(bottom=0.05, right=0.95, top=0.9, left=0.05)

size = 4
bufsize = 2**7
color = ["red", "green", "blue", "cyan"]
label = ["fan", "lamp", "monitor", "laptop"]

# Ground truth
gt_ax = fig.add_subplot(211)

x = np.zeros(bufsize)
for j in range(bufsize):
	x[j] = j
y = np.zeros(bufsize)

gt_y = []
for j in range(size):
	gt_y.append(np.zeros(bufsize+1))

# Estimation
es_ax = fig.add_subplot(212)

def init():
	try:
		thread.start_new_thread(udprx.GTThread, (gt_y,))
	except:
		print "Error creating thread. Exit now."
		quit

def animate(i):
	gt_y_clone = []
	gt_y_clone.append(y)
	for i in range(0, size):
		gt_y_clone.append(cbuf.cclone(gt_y[i]))

	gt_ax.cla()
	gt_ax.xaxis.set_visible(False)
	gt_ax.set_title("Ground truth")
	gt_ax.set_ylabel("Power (W)")
	gt_ax.set_ylim(0, 100)
	gt_ax.set_xlim(0, bufsize)
	gt_ax.grid(True)
	lg = []
	for i in range(0, len(gt_y_clone)-1):
		gt_ax.fill_between(x, gt_y_clone[i+1], gt_y_clone[i], color=color[i])
		tmp, = gt_ax.plot(x, y)
		lg.append(tmp)
	gt_ax.legend(lg, label, loc=2)

	gt_y_clone1 = []
	gt_y_clone1.append(y)
	for i in range(1, len(gt_y_clone)):
		tmp = []
		for j in range(bufsize):
			tmp.append(gt_y_clone[i][j] + random.randint(0, 2) - 1)
		gt_y_clone1.append(tmp)

	es_ax.cla()
	es_ax.xaxis.set_visible(False)
	es_ax.set_title("Estimation")
	es_ax.set_ylabel("Power (W)")
	es_ax.set_ylim(0, 100)
	es_ax.set_xlim(0, bufsize)
	es_ax.grid(True)
	for i in range(0, len(gt_y_clone1)-1):
		es_ax.fill_between(x, gt_y_clone1[i+1], gt_y_clone1[i], color=color[i])
	es_ax.legend(lg, label, loc=2)

	return 0

try:
	ani = animation.FuncAnimation(fig, animate, init_func=init, interval=500)
	plt.show()
except KeyboardInterrupt:
	quit
