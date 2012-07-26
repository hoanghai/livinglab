#ifndef SERIAL_MSG
#define SERIAL_MSG

#define BUF_SIZE 118

typedef nx_struct serial_msg {
	nxle_uint16_t data[BUF_SIZE];
	nxle_uint16_t start;
	nxle_uint16_t end;
}radio_msg_t;

enum {
  AM_SERIAL_MSG = 101,
	AM_SERIAL	= 6,
};

#endif
