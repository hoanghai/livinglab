#include "demo.h"
#include "pc_control_msg.h"
#include "splug_data_msg.h"
#include "amr_data_msg.h"

module BaseC @safe() {
	uses {
		interface Boot;

		// Radio
		interface Packet as RadioPacket;
		interface AMSend as RadioSend;
		interface SplitControl as RadioControl;

		interface Receive as SPlugRadioReceive;

		interface Receive as AMRRadioReceive;

		// Serial
		interface Receive as SerialReceive;
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
			splugRadioReceivedNotify();
			atomic {memcpy(splugData, (splug_data_msg_t*) payload, sizeof(splug_data_msg_t));}
			sendSPlugSerialMsg();
		}
		return bufPtr;
	}

	// Receive message from AMR
	// Forward to PC using sendAMRSerialMsg()
	event message_t* AMRRadioReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(amr_data_msg_t))
		{	
			amrRadioReceivedNotify();
			atomic {memcpy(amrData, (amr_data_msg_t*) payload, sizeof(amr_data_msg_t));}
			sendAMRSerialMsg();
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

	// Receive PC control message
	// Forward to node(s) using sendRadioMsg()
	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(pc_control_msg_t) && !lockRadio)
		{
			serialReceivedNotify();
			memcpy(&pcControl, (pc_control_msg_t*)payload, sizeof(pc_control_msg_t));
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
		baseControl = (base_control_msg_t *)call RadioPacket.getPayload(&baseControlPkt, sizeof(base_control_msg_t));
		splugData = (splug_data_msg_t *) call SPlugSerialPacket.getPayload(&splugDataPkt, sizeof(splug_data_msg_t));
		amrData = (amr_data_msg_t *) call AMRSerialPacket.getPayload(&amrDataPkt, sizeof(amr_data_msg_t));
	}
	
	event void Timer.fired() {}
}


