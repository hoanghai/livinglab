#include "demo.h"
#include "pc_control_msg.h"
#include "splug_data_msg.h"
#include "amr_data_msg.h"

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

	components new SerialAMSenderC(AM_SPLUG_DATA_MSG) as SPlugSerialSender;
	App.SPlugSerialPacket -> SPlugSerialSender;
	App.SPlugSerialSend -> SPlugSerialSender;

	components new SerialAMSenderC(AM_AMR_DATA_MSG) as AMRSerialSender;
	App.AMRSerialPacket -> AMRSerialSender;
	App.AMRSerialSend -> AMRSerialSender;

	components new TimerMilliC();
	App.Timer -> TimerMilliC;
}
