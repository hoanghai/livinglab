from scipy import *
from pylab import *
import thread

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.gridspec as gridspec

import cbuf
import udprx

fig = plt.figure()
fig.canvas.set_window_title("Raw data")
fig.subplots_adjust(bottom=0.05, right=0.95, top=0.95, left=0.05)

# P
p_bufsize = 2**7
p_ax = fig.add_subplot(311)
p_ax.set_title("Active Power from MSB")
p_ax.set_ylabel("Power (W)")
p_ax.set_ylim(0, 100)
p_ax.set_xlim(0, p_bufsize)
p_ax.xaxis.set_visible(False)
p_ax.grid(True)

p_x = np.zeros(p_bufsize)
for j in range(p_bufsize):
	p_x[j] = j
p_y = np.zeros(p_bufsize+1)

p_line, = p_ax.plot(p_x, p_y[0:p_bufsize])
p_ax.legend([p_line], ["Active Power"], loc=2)

# Z1
z1_bufsize = 2**8
z1_ax = fig.add_subplot(312)
z1_ax.set_title("Raw data from Veris CT Sensor")
z1_ax.set_ylim(0, 2**12)
z1_ax.set_xlim(0, z1_bufsize)
z1_ax.xaxis.set_visible(False)
z1_ax.yaxis.set_visible(False)

z1_x = np.zeros(z1_bufsize)
for j in range(z1_bufsize):
	z1_x[j] = j
z1_y = np.zeros(z1_bufsize+1)
z1_line, = z1_ax.plot(z1_x, z1_y[0:z1_bufsize])
z1_ax.legend([z1_line], ["Current"], loc=2)

# Motion
m_bufsize = 2**7
m_ax = fig.add_subplot(313)
m_ax.set_title("Raw data from Phidget PIR Sensor")
m_ax.set_ylim(0, 2**12)
m_ax.set_xlim(0, m_bufsize)
m_ax.xaxis.set_visible(False)
m_ax.yaxis.set_visible(False)

m_x = np.zeros(m_bufsize)
for j in range(m_bufsize):
	m_x[j] = j
m_y = np.zeros(m_bufsize+1)

m_line, = m_ax.plot(m_x, m_y[0:m_bufsize])
m_ax.legend([m_line], ["Motion"], loc=2)

def init():
	try:
		thread.start_new_thread(udprx.Z1Thread, (z1_y,))
		thread.start_new_thread(udprx.PThread, (p_y,))
		thread.start_new_thread(udprx.MThread, (m_y,))
	except:
		print "Error creating thread. Exit now."
		quit

def animate(i):
	z1_line.set_ydata(cbuf.cclone(z1_y))
	p_line.set_ydata(cbuf.cclone(p_y))
	m_line.set_ydata(cbuf.cclone(m_y))
	return 0

try:
	ani = animation.FuncAnimation(fig, animate, init_func=init, interval=100)
	plt.show()
except KeyboardInterrupt:
	quit
