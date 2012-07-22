#include "Timer.h"
#include "demo.h"
#include "amr_data_msg.h"

module AMRC @safe() {
	uses {
		interface Boot;
		interface Leds;

		interface AMSend;
		interface Receive;
		interface Packet;
		interface SplitControl as AMControl;

		interface Msp430Adc12SingleChannel as adc;
		interface Resource;

		interface Timer<TMilli> as MilliTimer;
	}
}
implementation {

	void adcLockNotify() {call Leds.led0Toggle();}
	void radioSentNotify() {call Leds.led1Toggle();}
	void radioLockNotify() {call Leds.led2Toggle();}

	bool repeat = FALSE;
	amr_data_msg_t *data;
	message_t packet;
	uint16_t counter = 0;
	bool radioLock = FALSE;
	bool adcLock = FALSE;
	
	// Double buffer
	int adcBuf = 0;
	int radioBuf = 0;
	uint16_t buf[2][AMR_DATA_MSG_LEN];

	msp430adc12_channel_config_t adcconfig = {
		inch: INPUT_CHANNEL_A7,
		sref: REFERENCE_AVcc_VREFnegterm,
		ref2_5v: REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_ACLK,
		adc12div: SHT_CLOCK_DIV_1,
		sht: SAMPLE_HOLD_256_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
		sampcon_id: SAMPCON_CLOCK_DIV_1
	};

	task void sendRadioMsg()
	{
		atomic
		{
			int i;
			for (i = 0; i < AMR_DATA_MSG_LEN; i++)
				data->current[i] = buf[radioBuf][i];

			data->counter = counter++;
			
			if (radioLock)
			{
				radioLockNotify();
				return;
			}
			if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(amr_data_msg_t)) == SUCCESS)
				radioLock = TRUE;
		}
	}

/*	ADC to Radio chain:
		- StartADC
		- ADC done callback:
			+ Send radio
			+ If REPEAT then StartADC again
*/
	void startADC()
	{
		atomic
		{
			adcBuf = 1 - adcBuf;
			call adc.configureMultiple(&adcconfig, buf[adcBuf], AMR_DATA_MSG_LEN, 0);
			call adc.getData();
			adcLock = TRUE;
		}
	}

	void execute(uint16_t cmd, uint16_t param1, uint16_t param2)
	{
		switch (cmd)
		{
			case AMR_SAMPLE:
				if (!adcLock)
					startADC();
				else
					adcLockNotify();
				break;
			case AMR_SAMPLE_REPEAT:
				if (!adcLock)
				{
					atomic {repeat = TRUE;}
					startADC();
				}
				else
					adcLockNotify();
				break;
			case AMR_SAMPLE_STOP:
				atomic {repeat = FALSE;}
				break;
			default:
				break;
		}
	}

	event void Boot.booted() {
		call Resource.request();
	}

	event void Resource.granted()
	{
		call AMControl.start();
		data = (amr_data_msg_t*)call Packet.getPayload(&packet, sizeof(amr_data_msg_t));
	}

	async event uint16_t *adc.multipleDataReady(uint16_t *buffer, uint16_t numSamples)
	{
		atomic 
		{
			adcLock = FALSE;
			radioBuf = adcBuf;
		}
		post sendRadioMsg();
		if (repeat)
			startADC();
		
		return SUCCESS;
	}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		if (len == sizeof(base_control_msg_t))
		{	
			base_control_msg_t *control = (base_control_msg_t*) payload;
			execute(control->cmd, control->param1, control->param2);
		}

		return bufPtr;
	}

	event void AMSend.sendDone(message_t* bufPtr, error_t error)
	{
		if (&packet == bufPtr)
			radioSentNotify();
		atomic {radioLock = FALSE;}
	}

	async event error_t adc.singleDataReady(uint16_t buffer)
	{
		return SUCCESS;
	}

	event void AMControl.startDone(error_t err)
	{
		if (err != SUCCESS)
			call AMControl.start();
	}

	event void AMControl.stopDone(error_t err) {}

	event void MilliTimer.fired() {}
}




