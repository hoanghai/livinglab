#ifndef SPLUG_DATA_MSG_H
#define SPLUG_DATA_MSG_H

#define CURRENT 			0x02//0x16
#define CURRENT_SIZE 		3

enum {
	AM_SPLUG_DATA_MSG = 89,
};

typedef nx_struct splug_data_msg {
	nx_uint16_t nodeID;
	nx_uint16_t counter;
	nx_uint16_t state;	// ON/OFF
	nx_uint8_t current[CURRENT_SIZE];
} splug_data_msg_t;

#endif
