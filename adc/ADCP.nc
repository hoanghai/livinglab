configuration ADCP
{ 
}

implementation { 
	components ADCC as App, MainC, LedsC;

	App.Boot -> MainC;
	App.Leds -> LedsC;

	components new TimerMilliC();
	App.Timer -> TimerMilliC;

	components new Phidget5VC();
	App.Read -> Phidget5VC;  
}
