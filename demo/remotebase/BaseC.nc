#include "demo.h"

module BaseC @safe() {
	uses {
		interface Boot;

		// Radio
		interface SplitControl as RadioControl;
		interface Packet as RadioPacket;
		interface AMSend as RadioSend;
		interface Receive as ControlRadioReceive;
		interface Receive as SPlugRadioReceive;
		interface Receive as AMRRadioReceive;

		// Serial
		interface SplitControl as SerialControl;
		interface Packet as SPlugSerialPacket;
		interface AMSend as SPlugSerialSend;
		interface Packet as AMRSerialPacket;
		interface AMSend as AMRSerialSend;

		interface Leds;

		interface Timer<TMilli>;
	}
}
implementation {
	void splugRadioReceivedNotify() 	{call Leds.led0Toggle();}
	void amrRadioReceivedNotify() 		{call Leds.led2Toggle();}
    void controlRadioReceivedNotify() {}
	void radioSendDoneNotify() 			{call Leds.led1Toggle();}
	void serialReceivedNotify() {}
	void serialSendDoneNotify() {}

	// Send Radio (Base Control)
	void sendRadioMsg();
	base_control_msg_t *baseControl;
	message_t baseControlPkt;

	// Receive Serial (PC Control)
	pc_control_msg_t pcControl;

	// SPlug: Receive Radio / Send Serial
	splug_data_msg_t *splugData;
	message_t splugDataPkt;
	void sendSPlugSerialMsg();

	// AMR: Receive Radio / Send Serial
	amr_data_msg_t *amrData;
	message_t amrDataPkt;
	void sendAMRSerialMsg();

	// Others
	bool lockRadio = FALSE;
	bool lockSerial = FALSE;

/**************
	Radio
**************/

	// Send command from base to node
	// Need to convert from pc_control_msg to base_control_msg
	void sendRadioMsg()
	{
		atomic
		{
			if (lockRadio)
				return;

			baseControl->cmd = pcControl.param[1];
			baseControl->param1 = pcControl.param[2];
			baseControl->param2 = pcControl.param[3];

			if (call RadioSend.send(pcControl.param[0], &baseControlPkt, sizeof(base_control_msg_t)) == SUCCESS)
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

	// Receive message from SPlug
	// Forward to PC using sendSplugSerialMsg()
	event message_t* SPlugRadioReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(splug_data_msg_t))
		{	
			atomic {
              int i;
              splug_data_msg_t *data = (splug_data_msg_t*) payload;
              splugData->nodeID = data->nodeID;
              splugData->counter = data->counter;
              splugData->state = data->state;
              for (i = 0; i < CURRENT_SIZE; i++)
                splugData->current[i] = data->current[i];
              for (i = 0; i < AENERGY_SIZE; i++)
                splugData->aenergy[i] = data->aenergy[i];
            }
            splugRadioReceivedNotify();
			sendSPlugSerialMsg();
		}
		return bufPtr;
	}

	// Receive message from AMR
	// Forward to PC using sendAMRSerialMsg()
	event message_t* AMRRadioReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(amr_data_msg_t))
		{	
			atomic {
              int i;
              amr_data_msg_t * data = (amr_data_msg_t*) payload;
              amrData->counter = data->counter;
              for (i = 0; i < AMR_DATA_MSG_LEN; i++)
                amrData->current[i] = data->current[i];
            }
            amrRadioReceivedNotify();
			sendAMRSerialMsg();
		}
		return bufPtr;
	}

	// Receive PC control message
	// Forward to node(s) using sendRadioMsg()
	event message_t* ControlRadioReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(pc_control_msg_t) && !lockRadio)
		{
          atomic {
            int i;
            pc_control_msg_t *control = (pc_control_msg_t*)payload;
            for (i = 0; i < PC_CONTROL_MSG_LEN; i++)
              pcControl.param[i] = control->param[i];
          }
          controlRadioReceivedNotify();
          sendRadioMsg();
			
		}
		return bufPtr;
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

	// Forward SPlug radio msg to PC
	void sendSPlugSerialMsg()
	{
		atomic
		{
			if (lockSerial)
				return;
			if (call SPlugSerialSend.send(AM_BROADCAST_ADDR, &splugDataPkt, sizeof(splug_data_msg_t)) == SUCCESS)
				lockSerial = TRUE;
		}
	}

	event void SPlugSerialSend.sendDone(message_t* msg, error_t error)
	{
		if (error == SUCCESS)
			serialSendDoneNotify();
		atomic {lockSerial = FALSE;} // no resend
	}

	// Forward AMR radio msg to PC
	void sendAMRSerialMsg()
	{
		atomic
		{
			if (lockSerial)
				return;
			if (call AMRSerialSend.send(AM_BROADCAST_ADDR, &amrDataPkt, sizeof(amr_data_msg_t)) == SUCCESS)
				lockSerial = TRUE;
		}
	}

	event void AMRSerialSend.sendDone(message_t* msg, error_t error)
	{
		if (error == SUCCESS)
			serialSendDoneNotify();
		atomic {lockSerial = FALSE;} // no resend
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
		baseControl = (base_control_msg_t *)call RadioPacket.getPayload(&baseControlPkt, sizeof(base_control_msg_t));
		splugData = (splug_data_msg_t *) call SPlugSerialPacket.getPayload(&splugDataPkt, sizeof(splug_data_msg_t));
		amrData = (amr_data_msg_t *) call AMRSerialPacket.getPayload(&amrDataPkt, sizeof(amr_data_msg_t));
	}
	
	event void Timer.fired() {}
}


