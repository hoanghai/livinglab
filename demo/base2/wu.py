import sys
import serial
import traceback
from datetime import datetime
import time
import os
import binascii
import thread
import socket
import math

activep = 0
reactivep = 0

def readWUThread(wuport, DEBUG):
	global activep, reactivep
	serialwu = serial.Serial(wuport, 115200, timeout=2)
	
	while True:
		try:	
			line = serialwu.readline().rstrip("\n")
			tmp = line.rsplit(",")
			activep = int(tmp[3])
			pf = int(tmp[16])/100.0
			apparentp = activep / pf
			reactivep = int(math.sqrt(apparentp * apparentp - activep * activep))
			if DEBUG == True:
				print activep, pf, reactivep
		except:
			print "readWUThread error"
			pass#traceback.print_exc(file=sys.stdout)
	serialwu.close()
