#include "demo.h"

configuration SPlugC { 
	provides interface SPlugControl;
}

implementation {
	components MainC, SPlugP, new TimerMilliC() as Timer1, new TimerMilliC() as Timer2, LedsC;
	SPlugControl = SPlugP;
	SPlugP.SampleTimer -> Timer1;
	SPlugP.PowerTimer -> Timer2;
	SPlugP.Leds -> LedsC;

	components ADE7763C;
	SPlugP.Spi -> ADE7763C; 

	components BusyWaitMicroC;
	SPlugP.BusyWait -> BusyWaitMicroC;

	components HplMsp430GeneralIOC, new Msp430GpioC() as port51g;
	port51g.HplGeneralIO -> HplMsp430GeneralIOC.Port51;
	SPlugP.GeneralIO -> port51g;

	components RandomC;
	SPlugP.Random -> RandomC;
}
