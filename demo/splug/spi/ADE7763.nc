interface ADE7763 {
	command void init(); 
	command void powerOn();
	command void powerOff();
	command void writeCommand(uint8_t data); 
	command void setMode(uint8_t data); 
	command void writeData(uint8_t data, uint8_t rx_len); 
	command void cs_high();
	command void cs_low();
	event void readData(nx_uint8_t* rx_buf, uint8_t len);
	command void Clk_clr();
	command void Clk_set();

	command void cs_toggle();
	command void mosi_toggle(); 
	command void miso_toggle(); 
	command void sck_toggle(); 
}

