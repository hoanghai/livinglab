#include "demo.h"

interface SPlugControl
{
	command error_t start();
	command error_t samplePeriodic(uint16_t repeatTime, uint16_t random);
	command error_t sample();
	command error_t sampleStop();
	event void sampleDataReady(splug_data_msg_t* data);

	command error_t powerOn();
	command error_t powerOff();
	command error_t powerToggle();
	command error_t powerTogglePeriodic(uint16_t toggleTime);
	command error_t powerToggleStop();
}
