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
	uint16_t counter = 0;

	void dataMsgSentNotify() {call Leds.led1Toggle();}

	void sendRadioMsg(splug_data_msg_t* _data)
	{
		splug_data_msg_t* data = (splug_data_msg_t*)call Packet.getPayload(&packet, sizeof(splug_data_msg_t));
		if (data == NULL || lockRadio)
			return;

		data->nodeID = TOS_NODE_ID;
		data->counter = counter;
		data->state = _data->state;
		memcpy(&(data->current), &(_data->current), CURRENT_SIZE);
		memcpy(&(data->aenergy), &(_data->aenergy), AENERGY_SIZE);

		if (call AMSend.send(BASE_ID, &packet, sizeof(splug_data_msg_t)) == SUCCESS)
        {
			lockRadio = TRUE;
            counter = (counter + 1) & 255;
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

	event void SPlugControl.sampleDataReady(splug_data_msg_t* _data)
	{
		sendRadioMsg(_data);
	}

	event void AMSend.sendDone(message_t* msg, error_t error)
	{
		lockRadio = FALSE;
		dataMsgSentNotify();
	}

	event void AMControl.startDone(error_t err)
	{
		if (err != SUCCESS)
			call AMControl.start();
		else
		{
			call SPlugControl.powerOn();
			call SPlugControl.samplePeriodic(500, 500);
		}
	}

	event void AMControl.stopDone(error_t err) {}
}

