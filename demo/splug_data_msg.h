#ifndef SPLUG_DATA_MSG_H
#define SPLUG_DATA_MSG_H

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

#endif
