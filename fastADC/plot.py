#!/usr/bin/python

import sys
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pylab

import datetime
from matplotlib.pyplot import figure, show
from matplotlib.dates import DayLocator, HourLocator, DateFormatter, drange, MinuteLocator
from numpy import arange

#open file
openfile = open("tmp", "r")

#read file
count = 0
yList = []
for line in openfile:
	try:
		y = line.split(' ')
		yList.append(float(y[2]))
	except:
		print "Error at line:", count
	count += 1

print "Count=%d" %count

#plot
fig = plt.figure()

ax1 = fig.add_subplot(111)
#ax1.set_ylim(0, 1.0)

#ax1.plot(dates, y1, 'r', linewidth=2)

#plt.figure()
n, bin, patches = plt.hist(yList, 2000, normed=1, facecolor='b', alpha=1)

plt.show()
