import sys, os, random
from PyQt4 import QtGui, QtCore

from numpy import arange, sin, pi
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

class MyMplCanvas(FigureCanvas):
	def __init__(self, parent=None, width=5, height=4, dpi=100):
		fig = Figure(figsize=(width, height), dpi=dpi)
		self.axis1 = fig.add_subplot(211)
		self.axis2 = fig.add_subplot(212)
		self.axis1.hold(False)
		self.axis2.hold(False)
		
		FigureCanvas.__init__(self, fig)
		self.setParent(parent)
		
		FigureCanvas.setSizePolicy(self,
															 QtGui.QSizePolicy.Expanding,
															 QtGui.QSizePolicy.Expanding)
		FigureCanvas.updateGeometry(self)

class MyDynamicMplCanvas(MyMplCanvas):
    def __init__(self, *args, **kwargs):
        MyMplCanvas.__init__(self, *args, **kwargs)
        timer = QtCore.QTimer(self)
				self.x1 = args[0]
				self.y1 = args[1]
				print self.x1, self.y1
        QtCore.QObject.connect(timer, QtCore.SIGNAL("timeout()"), self.update_figure)
        timer.start(100)

    def update_figure(self):
        l = [ random.randint(0, 10) for i in xrange(4) ]
        self.axis1.plot([0, 1, 2, 3], l, 'r')
        self.axis2.plot([0, 1, 2, 3], l, 'r')
        self.draw()

class ApplicationWindow(QtGui.QMainWindow):
    def __init__(self):
        QtGui.QMainWindow.__init__(self)
        self.setAttribute(QtCore.Qt.WA_DeleteOnClose)
        self.setWindowTitle("application main window")

        self.main_widget = QtGui.QWidget(self)

        l = QtGui.QVBoxLayout(self.main_widget)
        dc1 = MyDynamicMplCanvas(self.main_widget, width=5, height=4, dpi=100)
        dc2 = MyDynamicMplCanvas(self.main_widget, width=5, height=4, dpi=100)
        l.addWidget(dc1)
        l.addWidget(dc2)

        self.main_widget.setFocus()
        self.setCentralWidget(self.main_widget)

        self.statusBar().showMessage("All hail matplotlib!", 2000)

qApp = QtGui.QApplication(sys.argv)

aw = ApplicationWindow()
aw.setWindowTitle("This is a title")
aw.show()
sys.exit(qApp.exec_())
