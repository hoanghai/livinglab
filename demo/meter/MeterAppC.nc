#include "demo.h"
#include "splug_data_msg.h"

configuration MeterAppC
{
}
implementation
{
	components MainC, MeterC as App, LedsC;
	App -> MainC.Boot;
	App.Leds -> LedsC;

	components SPlugC;
	App.SPlugControl -> SPlugC;

	components ActiveMessageC, new AMReceiverC(AM_BASE_CONTROL_MSG), new AMSenderC(AM_SPLUG_DATA_MSG);
	App.AMSend -> AMSenderC;
	App.Packet -> AMSenderC;
	App.Receive -> AMReceiverC;
	App.AMControl -> ActiveMessageC;
}

