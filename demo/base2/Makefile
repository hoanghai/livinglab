COMPONENT=BaseAppC
BUILD_EXTRA_DEPS += PCComm.class
CLEAN_EXTRA = *.class PCControlMsg.java PCDataMsg.java SPlugDataMsg.java AMRDataMsg.java

CFLAGS += -DPRINTFUART_ENABLED
PFLAGS += -I../ -I../splug/ -I../splug/spi
CFLAGS += -DTOSH_DATA_LENGTH=120
CFLAGS += -I$(TOSDIR)/lib/T2Hack

PCComm.class: $(wildcard *.java) PCControlMsg.java PCDataMsg.java SPlugDataMsg.java AMRDataMsg.java NodeList.java
	javac -target 1.5 -source 1.5 *.java

PCControlMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=PCControlMsg ../demo.h pc_control_msg -o $@

PCDataMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=PCDataMsg ../demo.h pc_data_msg -o $@

SPlugDataMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=SPlugDataMsg ../demo.h splug_data_msg -o $@

AMRDataMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=AMRDataMsg ../demo.h amr_data_msg -o $@

include $(MAKERULES)