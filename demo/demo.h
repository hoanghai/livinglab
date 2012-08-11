#ifndef DEMO_H
#define DEMO_H

/***********
DEMO
***********/
#define BASE_ID				20

enum {
	AM_PC_CONTROL_MSG = 137,
  AM_PC_DATA_MSG = 138,
  AM_BASE_CONTROL_MSG = 88,
  AM_SPLUG_DATA_MSG = 89,
	AM_AMR_DATA_MSG = 90,
};

/**************
PC_CONTROL_MSG
Control msg from PC to BASE
**************/
#define	PC_CONTROL_MSG_LEN 6

typedef nx_struct pc_control_msg {
  nx_uint16_t param[PC_CONTROL_MSG_LEN];
} pc_control_msg_t;

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
	AMR_SAMPLE_STOP = 11,
};

/*************
PC_DATA_MSG
Data msg from METER or AMR to PC
*************/
#define PC_DATA_MSG_LEN 40

enum {
  PC_DATA_SPLUG_TYPE = 0,
  PC_DATA_AMR_TYPE = 1,
};

typedef nx_struct pc_data_msg {
  nx_uint8_t type;
  nx_uint8_t counter;
  nx_uint8_t data[PC_DATA_MSG_LEN];
} pc_data_msg_t;

/**************
BASE_CONTROL_MSG
Control msg from BASE to METER or AMR
**************/
typedef nx_struct base_control_msg {
	nx_uint16_t cmd; 
	nx_uint16_t param1;
	nx_uint16_t param2;
} base_control_msg_t;

/*************
SPLUG_DATA_MSG
SPLUG data from SPLUG to BASE
*************/
#define CURRENT 0x16
#define CURRENT_SIZE 3

#define AENERGY 0x02
#define AENERGY_SIZE 3

#define VAENERGY 0x05
#define VAENERGY_SIZE 3

enum {
  SPLUG_DATA_OFF_STATE = 0,
  SPLUG_DATA_ON_STATE = 1,
};

typedef nx_struct splug_data_msg {
	nx_uint8_t nodeID;
	nx_uint8_t counter;
	nx_uint8_t state;
	nx_uint8_t current[CURRENT_SIZE];
  nx_uint8_t aenergy[AENERGY_SIZE];
} splug_data_msg_t;

/*************
AMR_DATA_MSG
AMR data from Z1 to BASE
*************/
#define AMR_DATA_MSG_LEN	25

typedef nx_struct amr_data_msg {
  nx_uint8_t nodeID;
	nx_uint8_t counter;
	nx_uint16_t current[AMR_DATA_MSG_LEN];
} amr_data_msg_t;

/*************
NODELIST
*************/
#define SPLUG_MAX_NUM 10

struct node {
  uint8_t nodeID;
  uint8_t counter;
  uint8_t state;
  uint8_t dirty;
  uint8_t current[CURRENT_SIZE];
};

struct nodelist {
  uint8_t num;
  uint8_t counter;
  struct node node[SPLUG_MAX_NUM];
};

int findNode(int);
void updateNode(int, int, int, int);
void nodelist2splugPCData();
#endif

