#include "demo.h"

module BaseC @safe() {
	uses {
		interface Boot;

		// Radio
		interface Packet as RadioPacket;
		interface AMSend as RadioSend;
		interface SplitControl as RadioControl;

		interface Receive as SPlugRadioReceive;

		interface Receive as AMRRadioReceive;

		// Serial
		interface Receive as SerialReceive;
		interface SplitControl as SerialControl;

		interface Packet as SerialPacket;
		interface AMSend as SerialSend;

		interface Leds;

		interface Timer<TMilli>;
	}
}
implementation {
	void splugRadioReceivedNotify() 	{call Leds.led0Toggle();}
	void amrRadioReceivedNotify() 		{call Leds.led2Toggle();}
	void radioSendDoneNotify() 			{call Leds.led1Toggle();}

	// Send Radio (Base Control)
	base_control_msg_t *baseControl;
	message_t baseControlPkt;

	// SPlug: Receive Radio
  pc_data_msg_t *pcData;
	message_t pcDataPkt;

  struct nodelist nodelist;

	// Others
	bool lockRadio = FALSE;
	bool lockSerial = FALSE;

/**************
Nodelist
**************/
  int findNode(int id)
  {
    int i;
    for (i = 0; i < nodelist.num; i++)
      if (nodelist.node[i].nodeID == id)
        return i;
    return -1;
  }

  void updateNode(uint8_t id, uint8_t counter, uint8_t state, uint8_t* current)
  {
    int i, j;
    i = findNode(id);
    if (i == -1) {
      if (nodelist.num == SPLUG_MAX_NUM) // Cannot add more node
        return;
      else { // Add node to nodelist
        i = nodelist.num;
        nodelist.node[i].nodeID = id;
        nodelist.node[i].dirty = 1;
        nodelist.num++;
      }
    }
    // Update nodelist with new values
    nodelist.node[i].counter = counter;
    nodelist.node[i].state = state;
    for (j = 0; j < CURRENT_SIZE; j++)
      nodelist.node[i].current[j] = *(current+j);
    nodelist.node[i].dirty = 1;
  }

  void nodelist2pcData() {
    int i, j, k;

    pcData->type = PC_DATA_SPLUG_TYPE;
    pcData->counter = nodelist.counter++;

    // Update new data
    j = 0;
    pcData->data[j++] = nodelist.num;
    for (i = 0; i < nodelist.num; i++) {
      pcData->data[j++] = nodelist.node[i].nodeID;
      pcData->data[j++] = nodelist.node[i].counter;
      pcData->data[j++] = nodelist.node[i].state;
      pcData->data[j++] = nodelist.node[i].dirty;
      for (k = 0; k < CURRENT_SIZE; k++)
        pcData->data[j++] = nodelist.node[i].current[k];
      nodelist.node[i].dirty = 0;
    }
  }

/**************
	Radio
**************/
	// Receive message from SPlug, update nodelist
	event message_t* SPlugRadioReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(splug_data_msg_t))
		{
      atomic {
        splug_data_msg_t *data;
        splugRadioReceivedNotify();
        data = (splug_data_msg_t*) payload;
        updateNode(data->nodeID, data->counter, data->state, &(data->current[0]));
      }
		}
		return bufPtr;
	}

	// Receive message from AMR, TODO: implement
	event message_t* AMRRadioReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len == sizeof(amr_data_msg_t))
      return bufPtr;
	}

	event void RadioSend.sendDone(message_t* msg, error_t error)
	{
		if (error == SUCCESS)
			radioSendDoneNotify();
		atomic {lockRadio = FALSE;}
	}

	event void RadioControl.startDone(error_t err)
	{
		if (err != SUCCESS)
			call RadioControl.start();
	}

	event void RadioControl.stopDone(error_t err) {}

/**************
	Serial
**************/
	event void SerialSend.sendDone(message_t* msg, error_t error)
	{
		atomic {lockSerial = FALSE;} // no resend
	}

	// Receive PC control message, forward to SPLUG or AMR node
	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len)
  {
		if (len == sizeof(pc_control_msg_t) && !lockRadio)
		{
      atomic {
        pc_control_msg_t *pcControl = (pc_control_msg_t*)payload;
        baseControl->cmd = pcControl->param[1];
        baseControl->param1 = pcControl->param[2];
        baseControl->param2 = pcControl->param[3];

        if (call RadioSend.send(pcControl->param[0], &baseControlPkt, sizeof(base_control_msg_t)) == SUCCESS)
          lockRadio = TRUE;
			}
		}
		return bufPtr;
	}

	event void SerialControl.startDone(error_t err)
	{
		if (err != SUCCESS)
			call SerialControl.start();
	}

	event void SerialControl.stopDone(error_t err) {}

/**************
Timer
**************/
	event void Timer.fired(){
    if (!lockSerial)
      atomic {
        nodelist2pcData();
        if (call SerialSend.send(AM_BROADCAST_ADDR, &pcDataPkt, sizeof(pc_data_msg_t)) == SUCCESS)
          lockSerial = TRUE;
      }
  }

/**************
	 Boot
**************/
	event void Boot.booted()
	{
		call RadioControl.start();
		call SerialControl.start();

		// Init global data structs
		baseControl = (base_control_msg_t *)call RadioPacket.getPayload(&baseControlPkt, sizeof(base_control_msg_t));

    pcData = (pc_data_msg_t *) call SerialPacket.getPayload(&pcDataPkt, sizeof(pc_data_msg_t));

    nodelist.num = 0;
    
    call Timer.startPeriodic(1000);
	}
}


