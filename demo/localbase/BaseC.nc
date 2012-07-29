#include "demo.h"

module BaseC @safe() {
	uses {
		interface Boot;

		// Radio Send
		interface Packet as RadioPacket;
		interface AMSend as RadioSend;
		interface SplitControl as RadioControl;

		// Serial Receive
		interface Receive as SerialReceive;
		interface SplitControl as SerialControl;

		interface Leds;

		interface Timer<TMilli>;
	}
}
implementation {
	void radioSendDoneNotify() 			{call Leds.led1Toggle();}
    void serialReceivedNotify() {}

	// Send Radio (Base Control)
	void sendRadioMsg();

	// Receive Serial (PC Control)
	pc_control_msg_t *pcControl;
	message_t pcControlPkt;

	// Others
	bool lockRadio = FALSE;
	bool lockSerial = FALSE;

/**************
	Radio
**************/

	// Send command from local base to remote base
	void sendRadioMsg()
	{
		atomic
		{
			if (lockRadio)
				return;

			if (call RadioSend.send(REMOTE_BASE_ID, &pcControlPkt, sizeof(pc_control_msg_t)) == SUCCESS)
				lockRadio = TRUE;
		}
	}

	event void RadioSend.sendDone(message_t* msg, error_t error)
	{
		if (error == SUCCESS)
		{
			radioSendDoneNotify();
			atomic {lockRadio = FALSE;}
		}
		else
			sendRadioMsg(); // Resend command msg if send error
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

	// Receive PC control message
	// Forward to remote base using sendRadioMsg()
	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(pc_control_msg_t) && !lockRadio)
		{
          atomic
          {
            pc_control_msg_t *control = (pc_control_msg_t*) payload;
            int i = 0;
            for (; i < PC_CONTROL_MSG_LEN;i++)
              pcControl->param[i] = control->param[i];
          }
			sendRadioMsg();
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
	 Boot
**************/
	event void Boot.booted()
	{
		call RadioControl.start();
		call SerialControl.start();

		// Init global data structs
		pcControl = (pc_control_msg_t *)call RadioPacket.getPayload(&pcControlPkt, sizeof(pc_control_msg_t));
	}
	
	event void Timer.fired()
    {
      pcControl->param[0] = 0;
      pcControl->param[1] = 1;
      sendRadioMsg();
    }
}


