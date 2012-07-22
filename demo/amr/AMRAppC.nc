#include "demo.h"
#include "amr_data_msg.h"

configuration AMRAppC {}
implementation {
	components MainC, AMRC as App, LedsC; 
	App.Boot -> MainC.Boot;
	App.Leds -> LedsC;

	components ActiveMessageC, new AMReceiverC(AM_BASE_CONTROL_MSG), new AMSenderC(AM_AMR_DATA_MSG);

	App.AMSend -> AMSenderC;
	App.Packet -> AMSenderC;
	App.Receive -> AMReceiverC;
	App.AMControl -> ActiveMessageC;

	components new Msp430Adc12ClientAutoDMAC() as Fadc;
	App.adc -> Fadc;
	App.Resource -> Fadc;

	components new TimerMilliC();
	App.MilliTimer -> TimerMilliC;
}


