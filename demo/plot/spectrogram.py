import sys
import matplotlib.pyplot as plt
import matplotlib.gridspec as gs

SCALE = 1.0
WINDOW_SIZE = 5000
SAMPLING_RATE = 3750

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
	gs = gs.GridSpec(3, 1)
	ax = plt.subplot(gs[0,:])
	ax.plot(y)
	#ax.set_xlim(0, length)

	ax = plt.subplot(gs[1:3,:])
	ax.specgram(y, NFFT=WINDOW_SIZE, Fs=int(rate), noverlap=0)
	#ax.set_xlim(0, length / rate)
	ax.set_ylim(0, 500)

	plt.show()
except KeyboardInterrupt:
	quit
