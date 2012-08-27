generic configuration Phidget5VC() {
  provides interface Read<uint16_t>;
}
implementation {
  components new AdcReadClientC();
  Read = AdcReadClientC;

  components Phidget5VP;
  AdcReadClientC.AdcConfigure -> Phidget5VP;
  
}
