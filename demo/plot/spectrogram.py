import sys
import matplotlib.pyplot as plt

SCALE = 1.0
WINDOW_SIZE = 20000
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
rate = float(sum(x)/len(y))
print len(y), rate

try:
	# plot
	fig = plt.figure()
	plt.plot(y)

	fig = plt.figure()
	plt.specgram(y, NFFT=WINDOW_SIZE, Fs=int(rate), noverlap=0)
	plt.ylim(0, 500)
	plt.show()
except KeyboardInterrupt:
	quit
