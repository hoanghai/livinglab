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

/*
SPLUG_DATA_MSG
*/
#define CURRENT 0x16
#define CURRENT_SIZE 3

#define AENERGY 0x02
#define AENERGY_SIZE 3

#define VAENERGY 0x05
#define VAENERGY_SIZE 3

enum {
	AM_SPLUG_DATA_MSG = 89,
};

typedef nx_struct splug_data_msg {
	nx_uint16_t nodeID;
	nx_uint16_t counter;
	nx_uint16_t state;
	nx_uint8_t current[CURRENT_SIZE];
    nx_uint8_t aenergy[AENERGY_SIZE];
    nx_uint8_t vaenergy[VAENERGY_SIZE];
} splug_data_msg_t;

/*
PC_CONTROL_MSG
*/
enum {
	AM_PC_CONTROL_MSG = 137,
	PC_CONTROL_MSG_LEN = 6,
};

typedef nx_struct pc_control_msg {
  nx_uint16_t param[PC_CONTROL_MSG_LEN];
} pc_control_msg_t;

/*
AMR_DATA_MSG
*/
#define AMR_DATA_MSG_LEN	25

enum {
	AM_AMR_DATA_MSG = 90,
};

typedef nx_struct amr_data_msg {
	nx_uint16_t counter;
	nx_uint16_t current[AMR_DATA_MSG_LEN];
} amr_data_msg_t;

#endif

