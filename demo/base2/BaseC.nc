#include "demo.h"

module BaseC @safe() {
	uses {
		interface Boot;

		// Radio
		interface Packet as RadioPacket;
		interface AMSend as RadioSend;
		interface SplitControl as RadioControl;
    interface PacketAcknowledgements;

		// Serial
		interface Receive as SerialReceive;
		interface SplitControl as SerialControl;

		interface Leds;

		interface Timer<TMilli>;
	}
}

implementation {
	void radioSendDoneNotify() {call Leds.led1Toggle();}
  void radioSendErrorNotify() {call Leds.led2Toggle();}

	message_t baseControlPkt;
  base_control_msg_t *baseControl;
  int nodeID;
  int MAX_RESEND_COUNT = 4;
  int resendCount = 0;
	bool lock = FALSE;

/**************
	Radio
**************/
  task void sendRadioMsg()
  {
    call PacketAcknowledgements.requestAck(&baseControlPkt);
    if (call RadioSend.send(nodeID, &baseControlPkt, sizeof(base_control_msg_t)) == FAIL)
      post sendRadioMsg();
  }

	event void RadioSend.sendDone(message_t* msg, error_t error)
	{
		if (error == SUCCESS && call PacketAcknowledgements.wasAcked(msg)) {  
			radioSendDoneNotify();
      atomic {lock = FALSE;}
    }
    else {
      radioSendErrorNotify();
      if (resendCount++ < MAX_RESEND_COUNT)
        call Timer.startOneShot(100); // 100ms delay until resend
      else
        atomic {lock = FALSE;} // stop resend, release radio
    }
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
		if (len == sizeof(pc_control_msg_t) && !lock)
		{
      pc_control_msg_t *pcControl;
      atomic {
        lock = TRUE;
        pcControl = (pc_control_msg_t*)payload;
        nodeID = pcControl->param[0];
        baseControl->cmd = pcControl->param[1];
        baseControl->param1 = pcControl->param[2];
        baseControl->param2 = pcControl->param[3];
        resendCount = 0;
			}
      post sendRadioMsg();
		}
		return bufPtr;
	}

	event void SerialControl.startDone(error_t err)
	{
		if (err != SUCCESS)
			call SerialControl.start();
    else
      baseControl = (base_control_msg_t *)call RadioPacket.getPayload(&baseControlPkt, sizeof(base_control_msg_t));
	}

	event void SerialControl.stopDone(error_t err) {}

/**************
Timer
**************/
	event void Timer.fired() {
    post sendRadioMsg();
  }

/**************
	 Boot
**************/
	event void Boot.booted()
	{
		call RadioControl.start();
		call SerialControl.start();
	}
}


