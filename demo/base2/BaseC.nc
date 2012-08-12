#include "demo.h"

module BaseC @safe() {
	uses {
		interface Boot;

		// Radio
		interface Packet as RadioPacket;
		interface AMSend as RadioSend;
		interface SplitControl as RadioControl;

		// Serial
		interface Receive as SerialReceive;
		interface SplitControl as SerialControl;

		interface Leds;

		interface Timer<TMilli>;
	}
}
implementation {
	void radioSendDoneNotify() 			{call Leds.led1Toggle();}

	// Send Radio
	message_t baseControlPkt;

	// Others
	bool lockRadio = FALSE;

/**************
	Radio
**************/
	event void RadioSend.sendDone(message_t* msg, error_t error)
	{
		if (error == SUCCESS)
			radioSendDoneNotify();
		atomic {lockRadio = FALSE;}
	}

	event void RadioControl.startDone(error_t err)
	{
		if (err != SUCCESS)
			call RadioControl.start();
	}

	event void RadioControl.stopDone(error_t err) {}

/**************
	Serial
**************/
	// Receive PC control message, forward to SPLUG or AMR node
	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len)
  {
		if (len == sizeof(pc_control_msg_t) && !lockRadio)
		{
      atomic {
        pc_control_msg_t *pcControl = (pc_control_msg_t*)payload;
        base_control_msg_t *baseControl = (base_control_msg_t *)call RadioPacket.getPayload(&baseControlPkt, sizeof(base_control_msg_t));
        baseControl->cmd = pcControl->param[1];
        baseControl->param1 = pcControl->param[2];
        baseControl->param2 = pcControl->param[3];

        if (call RadioSend.send(pcControl->param[0], &baseControlPkt, sizeof(base_control_msg_t)) == SUCCESS)
          lockRadio = TRUE;
			}
		}
		return bufPtr;
	}

	event void SerialControl.startDone(error_t err)
	{
		if (err != SUCCESS)
			call SerialControl.start();
	}

	event void SerialControl.stopDone(error_t err) {}

/**************
Timer
**************/
	event void Timer.fired() {}

/**************
	 Boot
**************/
	event void Boot.booted()
	{
		call RadioControl.start();
		call SerialControl.start();
	}
}


