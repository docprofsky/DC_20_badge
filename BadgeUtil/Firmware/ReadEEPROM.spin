CON
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000


  EEPROM_SCL      = 28
  EEPROM_DEVID    = $A0
  EEPROM_PAGESIZE = 128


  I2C_SCL                       = 28
  EEPROMAddr                    = %1010_0000

  debugMode     = 0

OBJ
  Serial        : "FullDuplexSerialPlusCog"
  i2c           : "basic_i2c_driver"

VAR

  long  buffer[32]

  long  address

  long  index

  long  readData


PUB main

  Serial.start(31, 30, 0, 115200, 2)

  i2c.Initialize(I2C_SCL)


  if debugMode == 1
    waitcnt(cnt + clkfreq * 4)
    readData := 0
  else

    readData := -1
     
    serial.rxFlush
    repeat while readData == -1
      readData := serial.rxCheck
     
  address := readData * $8000
   
  repeat 256  
   
    ' Read things 128 bytes at a time
    i2c.ReadPage(I2C_SCL, EEPROMAddr, address, @buffer, 128)
   
    repeat index from 0 to 127
      if debugMode == 1
        serial.hex(byte[@buffer][index],2)
        serial.tx(13)
      else
        serial.tx(byte[@buffer][index])
   
    address += $80

  waitcnt(cnt + clkfreq * 4)
  reboot
  
      
  