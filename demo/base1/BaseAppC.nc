#include "demo.h"

configuration BaseAppC {}
implementation {
	components MainC, BaseC as App, LedsC;
	App.Boot -> MainC.Boot;
	App.Leds -> LedsC;

	components ActiveMessageC;
	App.AMControl -> ActiveMessageC;

  components new AMSenderC(AM_BASE_CONTROL_MSG);
	App.Packet -> AMSenderC;
	App.AMSend -> AMSenderC;

  components new AMReceiverC(AM_SPLUG_DATA_MSG);
	App.Receive -> AMReceiverC;

	components new TimerMilliC();
	App.Timer -> TimerMilliC;

	components Counter32khz32C, new CounterToLocalTimeC(T32khz) as LocalTime32khzC;
	LocalTime32khzC.Counter -> Counter32khz32C;
	App.LocalTime     -> LocalTime32khzC;
}
