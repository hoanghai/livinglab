from scipy import *
from pylab import *
import sys
import matplotlib.pyplot as plt
import matplotlib.gridspec as gs
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

SCALE = 1.0
WINDOW_SIZE = 2000

# read file
openfile = open(sys.argv[1], "r")
x = []
y = []
for line in openfile:
	try:
		tmp = line.split()
		tmpx = float(tmp[0].rstrip())
		tmpy = SCALE*float(tmp[1].rstrip())
		x.append(tmpx)
		y.append(tmpy)
	except:
		pass
openfile.close()

length = len(x)
rate = float(sum(x) / length)
print length, rate

try:
	# plot
	gs = gs.GridSpec(4, 1)
	ax = plt.subplot(gs[0,:])
	ax.plot(y)
	ax.set_xlim(0, length)

	ax = plt.subplot(gs[1:3,:])
	pxx, freqs, bins, im = ax.specgram(y, NFFT=WINDOW_SIZE, Fs=int(rate), noverlap=0)
	ax.set_xlim(0, int(length / rate))
	ax.set_ylim(0, 1000)

	ax = plt.subplot(gs[3:4,:])
	npts = 2**15
	ft = fft(y[1570000:1570000+npts], npts)
	
	mgft=abs(ft)
	mgft /= np.max(mgft)
	ax.plot(mgft[0:npts/2+1])

	fig = plt.figure()
	ax = fig.add_subplot(111, projection='3d')
	x = np.zeros([len(freqs)/4, len(bins)])
	y = np.zeros([len(freqs)/4, len(bins)])
	z = np.zeros([len(freqs)/4, len(bins)])
	for i in range(len(freqs)/4):
		for j in range(len(bins)):
			x[i,j] = freqs[i]
			y[i,j] = bins[j]
			if i > 20:
				z[i,j] = pxx[i, j]
	ax.plot_wireframe(x, y, z, rstride=5, cstride=5)

	plt.show()
	
except KeyboardInterrupt:
	quit
