#include "Timer.h"
#include "serial_msg.h"

module FastADCC{

	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as TimerSample;
	uses interface Counter<T32khz,uint16_t> as MyCounter;

	uses interface Msp430Adc12SingleChannel as adc;
	uses interface Resource;


	uses interface Packet as SerialPacket;
	uses interface AMSend as SerialAMSend;
	uses interface SplitControl as SerialControl;
}

implementation{

	radio_msg_t * buf[2];
	message_t mypkt[2];
	uint16_t tmpbuf[BUF_SIZE];

	uint16_t idx = 0;
	uint16_t offset = 0;
	uint16_t offset2 = 0;
	msp430adc12_channel_config_t adcconfig = {
		inch: INPUT_CHANNEL_A7,
		sref: REFERENCE_AVcc_VREFnegterm,
		ref2_5v: REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_SMCLK,
		adc12div: SHT_CLOCK_DIV_2,
		sht: SAMPLE_HOLD_1024_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
		sampcon_id: SAMPCON_CLOCK_DIV_1
	};

	bool locked = FALSE;
	bool pending = FALSE;
	uint16_t prev, curr, elap;

	void showerror(){
		call Leds.led0On();
	}


	void configureMultiple(){
		error_t e;
//		e = call adc.configureMultiple(&adcconfig, buf[offset]->data, BUF_SIZE, 0);
		e = call adc.configureMultiple(&adcconfig, tmpbuf, BUF_SIZE, 0);
		if(e == FAIL)
			showerror();
	}


	event void Boot.booted(){
		uint8_t i, j;

		call SerialControl.start();

		for(i=0; i<2; i++) {
			buf[i] = (radio_msg_t*) call SerialPacket.getPayload(&(mypkt[i]), sizeof(radio_msg_t));				      
			if (buf[i] == NULL) {
				showerror();
				return;
			} else {
				for(j = 0; j < BUF_SIZE; j++) {
					buf[i]->data[j] = j;
				}
				buf[i]->start = 0xaaaa;
				buf[i]->end = 0xbbbb;
			}
		}

		if (call SerialPacket.maxPayloadLength() < sizeof(radio_msg_t))
			return;
		call Resource.request();
	}


	void sendSerial()
	{
		atomic{
		if (pending && !locked)
		{
			if (call SerialAMSend.send(AM_BROADCAST_ADDR, &(mypkt[offset2]), sizeof(radio_msg_t)) == SUCCESS)
			{
				call Leds.led2Toggle();
				locked = TRUE;
				pending = FALSE;
			}
		}
		}
	}

	event void SerialAMSend.sendDone(message_t* bufPtr, error_t error)
	{
		if (error != SUCCESS)
			showerror();
		locked = FALSE;
		if(pending) {
			configureMultiple();
			call adc.getData();
		}
		sendSerial();
	}

	event void SerialControl.startDone(error_t err) {}
	event void SerialControl.stopDone(error_t err) {}

	task void printSerial()
	{
		offset2 = 1 - offset;
		sendSerial();
	}

	event void TimerSample.fired(){
	}

	async event uint16_t *adc.multipleDataReady(uint16_t *buffer, uint16_t numSamples){
		int i = 0;
		atomic {
			for (i = 0; i < BUF_SIZE; i++)
				buf[offset]->data[i] = (uint16_t)(tmpbuf[i]<<2);
		}
		atomic{		
			pending = TRUE;
			atomic {buf[offset]->end = call MyCounter.get();}
			offset = 1 - offset;
			if(locked) {
				call Leds.led1Toggle(); 
				return;
			}
		}
		post printSerial();
		configureMultiple();
		atomic {buf[offset]->start = call MyCounter.get();}
		call adc.getData();
		return SUCCESS;
	}


	async event error_t adc.singleDataReady(uint16_t data)
	{
		return SUCCESS;
	}   

	event void Resource.granted(){

		configureMultiple();

		if(call adc.getData() == FAIL)
			showerror();
	} 

	async event void MyCounter.overflow() 
	{
		call MyCounter.clearOverflow();
	}
}

