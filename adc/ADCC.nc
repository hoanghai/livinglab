#include "Timer.h"
#include "printfZ1.h"
#define SAMPLING_RATE 100

module ADCC
{
	uses
	{
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as Timer;
   	interface Read<uint16_t> as Read;
	}
}

implementation
{
	event void Boot.booted()
	{
		printfz1_init();
		call Timer.startPeriodic(SAMPLING_RATE);
	}

	event void Timer.fired() 
	{
		call Read.read();
	}
	
 	event void Read.readDone(error_t error, uint16_t data)
	{
		if (error != SUCCESS)
			return;
    printfz1("%d\n", data);
	} 
}
