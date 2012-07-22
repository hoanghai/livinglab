module ADE7763P {
    provides
	{
        interface ADE7763;
    }
    uses {
        interface HplMsp430GeneralIO as SCK;
        interface HplMsp430GeneralIO as MISO;
        interface HplMsp430GeneralIO as MOSI;
        interface HplMsp430GeneralIO as CSB;

		interface Leds;
        interface BusyWait<TMicro,uint16_t>;
    }
}

implementation {
    
	inline void spi_clk() {
		call SCK.set();
   		call BusyWait.wait(10);
		call SCK.clr();
	}	

	command void ADE7763.init() {
		atomic {
			call SCK.makeOutput();
			call CSB.makeOutput();
			call MOSI.makeInput();
//			call MISO.makeInput();
			call MISO.makeOutput();
			call MOSI.clr();
			call CSB.set();
			call SCK.clr();
		}     
	}

    command void ADE7763.powerOn(){
//		call PWR.set();
//		TOSH_uwait(11000);
		call BusyWait.wait(5000);
		call BusyWait.wait(5000);
    }

    command void ADE7763.powerOff(){
//		call PWR.clr();
    }
    
	command void ADE7763.cs_high() {
		call CSB.set();
	}

	command void ADE7763.Clk_clr() {
		call SCK.clr();
	}

	command void ADE7763.Clk_set() {
		call SCK.set();
	}


    command void ADE7763.cs_low() {
        call CSB.clr();
    }

	command void ADE7763.cs_toggle() {
		call CSB.toggle();
	}

	command void ADE7763.mosi_toggle() {
		call MOSI.toggle();
	}

	command void ADE7763.miso_toggle() {
		call MISO.toggle();
	}
	command void ADE7763.sck_toggle() {
		call SCK.toggle();
	}

	command void ADE7763.setMode(uint8_t data) {
		uint16_t i;
		uint8_t commandValue = 0x0013;
		i = 0x80; // 1000|0000
   		call BusyWait.wait(10);
		//Send Command Byte
		call SCK.set();
		do {
			if (data & i) {
				call MISO.set();
			} else {
				call MISO.clr();				//Low
			}
			i = i>>1;
			atomic spi_clk();
		} while(i);
   		call BusyWait.wait(50);

		i = 0x8000; // 1000|0000
		//Send Significant Byte
		call SCK.set();
		do {
			if (commandValue & i) {
				call MISO.set();
			} else {
				call MISO.clr();				//Low
			}
			i = i>>1;
			atomic spi_clk();
		} while(i);
	}


	command void ADE7763.writeCommand(uint8_t data) {
		uint8_t	i;
		uint8_t commandValue = 0x44;
		i = 0x80; // 1000|0000
   		call BusyWait.wait(10);
		//Send Command Byte
		call SCK.set();
		do {
			if (data & i) {
				call MISO.set();
			} else {
				call MISO.clr();				//Low
			}
			i = i>>1;
			atomic spi_clk();
		} while(i);
   		call BusyWait.wait(50);

		i = 0x80; // 1000|0000
		//Send Significant Byte
		call SCK.set();
		do {
			if (commandValue & i) {
				call MISO.set();
			} else {
				call MISO.clr();				//Low
			}
			i = i>>1;
			atomic spi_clk();
		} while(i);
	}

	nx_uint8_t buf[4];
	void ADE7763_readData(uint8_t rx_len) {
		uint8_t i=1, rx;
		uint8_t len = rx_len;
		uint8_t bufCur=0;
		bufCur = sizeof(buf) - rx_len;
		
		call SCK.set();
		do{
			i  = 0x80; // 1000|0000
			rx = 0;
			do {
				atomic spi_clk();
				if (call MOSI.get())
					rx = rx + i;

				i = i>>1;

			} while(i);
			buf[bufCur++] = rx;
		} while(--len);
   		call BusyWait.wait(30000);
		signal ADE7763.readData(buf+(sizeof(buf)-rx_len), rx_len);
	}

	command void ADE7763.writeData(uint8_t data, uint8_t rx_len) {
		uint8_t	i;
		uint8_t rx=0;
		i = 0x80; // 1000|0000
   		call BusyWait.wait(10);
		call SCK.set();
		do {
			if (data & i) {
				call MISO.set();
				rx = rx + i;
			} else {
				call MISO.clr();				//Low
			}
			i = i>>1;
			atomic spi_clk();
		} while(i);
   		call BusyWait.wait(10);
		ADE7763_readData(rx_len);
	}
}
