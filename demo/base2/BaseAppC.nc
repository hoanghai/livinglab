#include "demo.h"

configuration BaseAppC {}
implementation {
	components MainC, BaseC as App, LedsC;
	App.Boot -> MainC.Boot;
	App.Leds -> LedsC;

	// Radio communication
	components ActiveMessageC, new AMSenderC(AM_BASE_CONTROL_MSG);;
	App.RadioPacket -> AMSenderC;
	App.RadioSend -> AMSenderC;
	App.RadioControl -> ActiveMessageC;
  App.PacketAcknowledgements -> ActiveMessageC;

	// Serial communication: receive command from PC
	components SerialActiveMessageC, new SerialAMReceiverC(AM_PC_CONTROL_MSG);
	App.SerialReceive -> SerialAMReceiverC;
	App.SerialControl -> SerialActiveMessageC;

	components new TimerMilliC();
	App.Timer -> TimerMilliC;
}

