#include "demo.h"
#include "printfZ1.h"

module BaseC @safe() {
	uses {
		interface Boot;

		interface Packet;
		interface AMSend;
		interface Receive;
		interface SplitControl as AMControl;

		interface Leds;

		interface Timer<TMilli>;
		interface LocalTime<T32khz>;
	}
}
implementation {

	void dataMsgReceivedNotify() {call Leds.led1Toggle();}

	event void Boot.booted() {
		printfz1_init();
		call AMControl.start();
	}

	event void Timer.fired() {}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(splug_data_msg_t))
		{	
			splug_data_msg_t *data = (splug_data_msg_t*) payload;
			uint8_t id = data->nodeID;
      uint8_t counter = data->counter;
      uint8_t state = data->state;
			uint8_t *aenergy = &(data->aenergy[0]);
      int i;
			printfz1("%d %d %d", id, counter, state);
      for (i = 0; i < AENERGY_SIZE; i++)
        printfz1(" %d", *(aenergy+i));
      printfz1("\n");
			dataMsgReceivedNotify();
		}
		return bufPtr;
	}

	event void AMControl.startDone(error_t err) {}

	event void AMControl.stopDone(error_t err) {}

	event void AMSend.sendDone(message_t* msg, error_t error) {}
}




