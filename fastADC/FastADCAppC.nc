#include "StorageVolumes.h"
#include "serial_msg.h"

configuration FastADCAppC { }

implementation {
  components MainC, FastADCC as App;
  App -> MainC.Boot;
  
  components LedsC;
  App.Leds -> LedsC;

  components SerialActiveMessageC as SerialAM;
  components new TimerMilliC() as TimerSample;
  App.TimerSample -> TimerSample;

components Msp430Counter32khzC as Counter;
App.MyCounter -> Counter;
  
  components new Msp430Adc12ClientAutoDMAC() as Fadc;
  App.adc -> Fadc;
  App.Resource -> Fadc;
  
//  components new BlockStorageC(VOLUME_BLOCKTEST);
//  App.BlockWrite -> BlockStorageC.BlockWrite;
//  App.BlockRead -> BlockStorageC.BlockRead;  

	App.SerialPacket -> SerialAM;
	App.SerialAMSend -> SerialAM.AMSend[AM_SERIAL_MSG];
	App.SerialControl -> SerialAM;
  
}

