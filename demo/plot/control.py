import sys
from PyQt4 import QtGui, QtCore

class Control(QtGui.QWidget):
	def __init__(self, control):
		super(Control, self).__init__()
		self.control = control
		self.initUI()

	def initUI(self):
		slider1 = 10
		slider2 = 190

		p_lbl1 = QtGui.QLabel("Active Power (WU)", self)
		p_lbl1.move(10, 10)
		self.p_lbl2 = QtGui.QLabel("stop", self)
		self.p_lbl2.move(210, 30)

		p_sld = QtGui.QSlider(QtCore.Qt.Horizontal, self)
		p_sld.setFocusPolicy(QtCore.Qt.NoFocus)
		p_sld.setGeometry(slider1, 30, slider2, 30)
		p_sld.valueChanged[int].connect(self.p_changeValue)

 		q_lbl1 = QtGui.QLabel("Reactive Power (WU)", self)
		q_lbl1.move(10, 70)
		self.q_lbl2 = QtGui.QLabel("stop", self)
		self.q_lbl2.move(210, 90)

		q_sld = QtGui.QSlider(QtCore.Qt.Horizontal, self)
		q_sld.setFocusPolicy(QtCore.Qt.NoFocus)
		q_sld.setGeometry(slider1, 90, slider2, 30)
		q_sld.valueChanged[int].connect(self.q_changeValue)

 		supp_lbl1 = QtGui.QLabel("Supplementary (Z1)", self)
		supp_lbl1.move(10, 130)
		self.supp_lbl2 = QtGui.QLabel("stop", self)
		self.supp_lbl2.move(210, 150)

		supp_sld = QtGui.QSlider(QtCore.Qt.Horizontal, self)
		supp_sld.setFocusPolicy(QtCore.Qt.NoFocus)
		supp_sld.setGeometry(slider1, 150, slider2, 30)
		supp_sld.valueChanged[int].connect(self.supp_changeValue)

		self.setGeometry(300, 300, 250, 200)
		self.setWindowTitle('Control')
		self.show()

	def p_changeValue(self, value):
		if value == 0:
			self.p_lbl2.setText("stop")
		else:
			self.p_lbl2.setText("%d"%value)
		self.control["p"] = value

	def q_changeValue(self, value):
		if value == 0:
			self.q_lbl2.setText("stop")
		else:
			self.q_lbl2.setText("%d"%value)
		self.control["q"] = value

	def supp_changeValue(self, value):
		if value == 0:
			self.supp_lbl2.setText("stop")
		else:
			self.supp_lbl2.setText("%d"%value)
		self.control["supp"] = value

def ControlThread(control):
	try:
		app = QtGui.QApplication(sys.argv)
		ex = Control(control)
		sys.exit(app.exec_())
	except:
		quit
