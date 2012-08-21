#include "Timer.h"
#include "demo.h"

module MeterC @safe()
{
	uses interface Boot;
	uses interface Leds;

	uses interface SPlugControl;

	uses interface Receive;
	uses interface AMSend;
	uses interface Packet;
	uses interface SplitControl as AMControl;
}

implementation
{
	message_t packet;
	bool lockRadio = FALSE;
	uint8_t counter = 0;

	void radioMsgSentNotify() {call Leds.led1Toggle();}
  void radioMsgErrorNotify() {call Leds.led2Toggle();}

	void sendRadioMsg(splug_data_msg_t* data)
	{
    int i;

		splug_data_msg_t* splugData = (splug_data_msg_t*)call Packet.getPayload(&packet, sizeof(splug_data_msg_t));
		if (splugData == NULL) return;

    atomic {
      splugData->nodeID = TOS_NODE_ID;
      splugData->counter = counter;
      splugData->state = data->state;
      for (i = 0; i < CURRENT_SIZE; i++)
        splugData->current[i] = data->current[i];
      for (i = 0; i < AENERGY_SIZE; i++)
        splugData->aenergy[i] = data->aenergy[i];
    }

    if (lockRadio) return;
		if (call AMSend.send(BASE_ID, &packet, sizeof(splug_data_msg_t)) == SUCCESS) {
			atomic {lockRadio = TRUE;}
      counter++;
    }
	}

	void execute(uint16_t cmd, uint16_t param1, uint16_t param2)
	{
		switch (cmd)
		{
			case SPLUG_SAMPLE_PERIODIC:
				call SPlugControl.samplePeriodic(param1, param2);
				break;
			case SPLUG_SAMPLE:
				call SPlugControl.sample();
				break;
			case SPLUG_SAMPLE_STOP:
				call SPlugControl.sampleStop();
				break;
			case SPLUG_POWER_ON:
				call SPlugControl.powerOn();
				break;
			case SPLUG_POWER_OFF:
				call SPlugControl.powerOff();
				break;
			case SPLUG_POWER_TOGGLE:
				call SPlugControl.powerToggle();
				break;
			case SPLUG_POWER_TOGGLE_PERIODIC:
				call SPlugControl.powerTogglePeriodic(param1);
				break;
			case SPLUG_POWER_TOGGLE_STOP:
				call SPlugControl.powerToggleStop();
				break;
			default:
				break;
		}
	}

	event void Boot.booted()
	{
		call SPlugControl.start();
		call AMControl.start();
	}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		if (len == sizeof(base_control_msg_t))
		{	
			base_control_msg_t *control = (base_control_msg_t*) payload;
			atomic {execute(control->cmd, control->param1, control->param2);}
		}
		return bufPtr;
	}

	event void SPlugControl.sampleDataReady(splug_data_msg_t* data)
	{
		sendRadioMsg(data);
	}

	event void AMSend.sendDone(message_t* msg, error_t error)
	{
		atomic {lockRadio = FALSE;}
		radioMsgSentNotify();
	}

	event void AMControl.startDone(error_t err)
	{
		if (err != SUCCESS)
			call AMControl.start();
		else
		{
			call SPlugControl.powerOn();
			call SPlugControl.samplePeriodic(950, 100);
		}
	}

	event void AMControl.stopDone(error_t err) {}
}

