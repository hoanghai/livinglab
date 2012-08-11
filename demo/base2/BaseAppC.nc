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

	components new AMReceiverC(AM_SPLUG_DATA_MSG) as SPlugRadioReceive; 
	App.SPlugRadioReceive -> SPlugRadioReceive;

	components new AMReceiverC(AM_AMR_DATA_MSG) as AMRRadioReceive; 
	App.AMRRadioReceive -> AMRRadioReceive;

	// Serial communication: receive command from PC
	components SerialActiveMessageC, new SerialAMReceiverC(AM_PC_CONTROL_MSG);
	App.SerialReceive -> SerialAMReceiverC;
	App.SerialControl -> SerialActiveMessageC;

	components new SerialAMSenderC(AM_SPLUG_DATA_MSG);
	App.SerialPacket -> SerialAMSenderC;
	App.SerialSend -> SerialAMSenderC;

	components new TimerMilliC();
	App.Timer -> TimerMilliC;
}
