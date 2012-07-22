// SCA61TC for inverted source.

configuration ADE7763C {
  provides interface ADE7763;
}

implementation {
	components ADE7763P;
	ADE7763 = ADE7763P;

	components BusyWaitMicroC;
	ADE7763P.BusyWait -> BusyWaitMicroC;

	components LedsC;
	ADE7763P.Leds -> LedsC;

	components HplMsp430GeneralIOC as IOC;
	ADE7763P.SCK  -> IOC.Port40;	//PSCLK
	ADE7763P.MISO -> IOC.Port35;	//PDOUT
	ADE7763P.MOSI -> IOC.Port34;	//PDIN
	ADE7763P.CSB  -> IOC.Port30;	//PCS

/* 
	new Msp430GpioC() as SCK,
	new Msp430GpioC() as MISO,
	new Msp430GpioC() as MOSI,
	new Msp430GpioC() as CSB;

	// UART1
	ADE7763P.MISO -> IOC.Port37;	//PDOUT
	ADE7763P.MOSI -> IOC.Port36;	//PDIN
	// UART0

	ADE7763P.SCK  -> IOC.Port17;
	ADE7763P.MISO -> IOC.Port26;
	ADE7763P.MOSI -> IOC.Port30;
	ADE7763P.CSB  -> IOC.Port21;
	ADE7763P.PWR  -> IOC.Port40;
	ADE7763P.PWRCK1  -> IOC.Port50;
	ADE7763P.PWRCK2  -> IOC.Port51;
	ADE7763P.PWRCK3  -> IOC.Port22;

	ADE7763P.PWR  -> IOC.Port40;
	ADE7763P.PWRCK1  -> IOC.Port50;
	ADE7763P.PWRCK2  -> IOC.Port51;
	ADE7763P.PWRCK3  -> IOC.Port22;
*/
}
