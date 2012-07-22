#ifndef AMR_DATA_MSG_H
#define AMR_DATA_MSG_H

#define AMR_DATA_MSG_LEN	25

enum {
	AM_AMR_DATA_MSG = 90,
};

typedef nx_struct amr_data_msg {
	nx_uint16_t counter;
	nx_uint16_t current[AMR_DATA_MSG_LEN];
} amr_data_msg_t;

#endif
