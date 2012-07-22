#ifndef PC_CONTROL_MSG_H
#define PC_CONTROL_MSG_H

enum {
	AM_PC_CONTROL_MSG = 137,
	PC_CONTROL_MSG_LEN = 6,
};

typedef nx_struct pc_control_msg {
  nx_uint16_t param[PC_CONTROL_MSG_LEN];
} pc_control_msg_t;

#endif
