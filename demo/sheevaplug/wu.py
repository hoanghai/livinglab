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
import serialtool as st

def readWUThread(DEBUG):
	while True:
		wuport = st.detect("FT232R USB UART", "A1017BXB", 0.5)
		wuserial = st.connect(wuport, 115200, 2, 0.5)

		while True:
			try:	
				line = wuserial.readline()
				if line == "":
					st.disconnect(wuserial)
					break
				line = line[1:len(line)-3]
				tmp = line.rsplit(",")
				activep = int(tmp[3])
				apparentp = int(tmp[20])
				pf = int(tmp[16])
				reactivep = int(math.sqrt(apparentp**2 - activep**2))
				if DEBUG == True:
					print line
				print activep, reactivep, apparentp
			except KeyboardInterrupt:
				quit()
			except:
				st.disconnect(wuserial)
				break
	serialwu.close()

readWUThread(True)

#print "readWUThread error"
#traceback.print_exc(file=sys.stdout)

