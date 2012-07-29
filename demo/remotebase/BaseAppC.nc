#include "demo.h"

configuration BaseAppC {}
implementation {
	components MainC, BaseC as App, LedsC;
	App.Boot -> MainC.Boot;
	App.Leds -> LedsC;

	// Radio communication
	components ActiveMessageC;
    App.RadioControl -> ActiveMessageC;

    components new AMSenderC(AM_BASE_CONTROL_MSG);
	App.RadioPacket -> AMSenderC;
	App.RadioSend -> AMSenderC;

    components new AMReceiverC(AM_PC_CONTROL_MSG) as ControlRadioReceive;
	App.ControlRadioReceive -> ControlRadioReceive;
	
	components new AMReceiverC(AM_SPLUG_DATA_MSG) as SPlugRadioReceive; 
	App.SPlugRadioReceive -> SPlugRadioReceive;

	components new AMReceiverC(AM_AMR_DATA_MSG) as AMRRadioReceive; 
	App.AMRRadioReceive -> AMRRadioReceive;

	// Serial communication
	components SerialActiveMessageC;
	App.SerialControl -> SerialActiveMessageC;

	components new SerialAMSenderC(AM_SPLUG_DATA_MSG) as SPlugSerialSender;
	App.SPlugSerialPacket -> SPlugSerialSender;
	App.SPlugSerialSend -> SPlugSerialSender;

	components new SerialAMSenderC(AM_AMR_DATA_MSG) as AMRSerialSender;
	App.AMRSerialPacket -> AMRSerialSender;
	App.AMRSerialSend -> AMRSerialSender;

	components new TimerMilliC();
	App.Timer -> TimerMilliC;
}
