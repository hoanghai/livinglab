#include "Timer.h"
#include "Serial.h"
#include "demo.h"

#define DEBUGGING TRUE

module SPlugP {
	provides
	{
		interface SPlugControl;
	}

	uses
	{
		interface ADE7763 as Spi;
		interface Timer<TMilli> as SampleTimer;
		interface Timer<TMilli> as PowerTimer;
		interface Leds;
		interface GeneralIO;
		interface BusyWait<TMicro,uint16_t> as BusyWait;
		interface Random;
	}
}

implementation {
	splug_data_msg_t local;
	bool readBusy = FALSE;	

	void dosmt() {}
	void powerOnNotify() {if (DEBUGGING) call Leds.led2On();}
	void powerOffNotify() {if (DEBUGGING) call Leds.led2Off();}
	void powerToggleNotify() {if (DEBUGGING) call Leds.led2Toggle();}
	void dataMsgSentNotify() {if (DEBUGGING) call Leds.led1Toggle();}

	command error_t SPlugControl.start() {
		call GeneralIO.makeOutput();
		call GeneralIO.set();

		call Spi.init();

		call Spi.cs_high();
		call Spi.cs_low();
		call Spi.writeCommand(0x8f);

#ifdef DCPLUG
#warning DCPLUG ENABLE
		call Spi.cs_high();
		call Spi.cs_low();
		call Spi.setMode(0x89);
#endif
		return SUCCESS;	
	}

	uint16_t state = 0;
	uint16_t repeat, random;
	error_t readData();
	uint16_t toggle;

/**************
	SAMPLE
**************/

	uint16_t getRandomTime()
	{
		uint16_t rnd = call Random.rand16();
		rnd &= random;
		rnd += repeat;
		return rnd;
	}

	command error_t SPlugControl.sampleStop() {
		if (call SampleTimer.isRunning()) call SampleTimer.stop();
		return SUCCESS;
	}

	command error_t SPlugControl.samplePeriodic(uint16_t repeatTime, uint16_t randomTime)
	{
		if (repeatTime <= 100)
			return FAIL;
		if (call SampleTimer.isRunning() && (repeat == repeatTime && random == randomTime))
			return FAIL;

		repeat = repeatTime;
		random = randomTime;
		call SampleTimer.stop();
		call SampleTimer.startOneShot(getRandomTime());
		return SUCCESS;	
	}

	command error_t SPlugControl.sample()
	{
		readData();
    return SUCCESS;
	}

	event void SampleTimer.fired()
	{
		readData();
		call SampleTimer.startOneShot(getRandomTime()); 
	}

  uint8_t readIdx = 0;
	error_t readData()
	{
		if(!readBusy) {
			readBusy = TRUE;
			call Spi.cs_low();
            switch (readIdx)
            {
				case 0:
					call Spi.writeData(CURRENT, CURRENT_SIZE); break;
				case 1:
					call Spi.writeData(AENERGY, AENERGY_SIZE); break;
				default:
					break;
			}
			return SUCCESS;
		}
		else
			return FALSE;
	}

    // Callback function from SPI (ADE7763 chip) signaling read done event
	event void Spi.readData(nx_uint8_t* rx_buf, uint8_t len) {
		call Spi.cs_high();
		switch (readIdx)
		{
			case 0:
				memcpy(&local.current, rx_buf, len); break;
			case 1:
				memcpy(&local.aenergy, rx_buf, len); break;
			default:
				break;
		}
		call Spi.cs_high();
		readBusy = FALSE;

		if (readIdx < 1)
		{
			readIdx++;
			readData();
		}
		else
		{
			readIdx = 0;
			local.state = state;
			signal SPlugControl.sampleDataReady(&local);
		}
	}

/**************
	POWER
**************/
	command error_t SPlugControl.powerOn()
	{
		if (call PowerTimer.isRunning()) call PowerTimer.stop();
		call GeneralIO.set();
		state = SPLUG_DATA_ON_STATE;
		powerOnNotify();
		return SUCCESS;
	}
	
	command error_t SPlugControl.powerOff() 
	{
		if (call PowerTimer.isRunning()) call PowerTimer.stop();
		call GeneralIO.clr();
		state = SPLUG_DATA_OFF_STATE;
		powerOffNotify();
		return SUCCESS;
	}

	command error_t SPlugControl.powerToggle()
	{
		if (call PowerTimer.isRunning()) call PowerTimer.stop();
		call GeneralIO.toggle();
		state = (state == SPLUG_DATA_ON_STATE) ?
      SPLUG_DATA_OFF_STATE : SPLUG_DATA_ON_STATE;
		powerToggleNotify();
		return SUCCESS;
	}

	command error_t SPlugControl.powerTogglePeriodic(uint16_t toggleTime)
	{
		if (toggleTime <= 100)
			return FAIL;
		if (call PowerTimer.isRunning() && toggle == toggleTime)
			return FAIL;

		toggle = toggleTime;
		call PowerTimer.stop();
		call PowerTimer.startPeriodic(toggle);
		return SUCCESS;
	}

	command error_t SPlugControl.powerToggleStop()
	{
		if (call PowerTimer.isRunning()) call PowerTimer.stop();
		return SUCCESS;
	}

	event void PowerTimer.fired()
	{
		call GeneralIO.toggle();
		state = (state == SPLUG_DATA_ON_STATE) ?
      SPLUG_DATA_OFF_STATE : SPLUG_DATA_ON_STATE;
		powerToggleNotify();
	}
}

