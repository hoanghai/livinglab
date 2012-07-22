/***********
	DEMO
***********/
#ifndef DEMO_H
#define DEMO_H

#define BASE_ID				40

#define AM_BASE_CONTROL_MSG 88

// Control msg from base to METER and AMR
typedef nx_struct base_control_msg {
	nx_uint16_t cmd; 
	nx_uint16_t param1;
	nx_uint16_t param2;
} base_control_msg_t;


// Control commands
enum {
	SPLUG_SAMPLE = 1,
	SPLUG_SAMPLE_PERIODIC = 2,
	SPLUG_SAMPLE_STOP = 3,

	SPLUG_POWER_ON = 4,
	SPLUG_POWER_OFF = 5,

	SPLUG_POWER_TOGGLE = 6,
	SPLUG_POWER_TOGGLE_PERIODIC = 7,
	SPLUG_POWER_TOGGLE_STOP = 8,

	AMR_SAMPLE = 9,
	AMR_SAMPLE_REPEAT = 10,
	AMR_SAMPLE_STOP = 11
};

#endif

