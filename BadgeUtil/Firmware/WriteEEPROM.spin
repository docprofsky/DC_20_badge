CON
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000


  EEPROM_SCL      = 28
  EEPROM_DEVID    = $A0
  EEPROM_PAGESIZE = 128


  I2C_SCL                       = 28
  EEPROMAddr                    = %1010_0000
  

OBJ
  Serial        : "FullDuplexSerialPlusCog"
  i2c           : "basic_i2c_driver"

VAR

  byte  buffer[128]

  long  address

  long  index

  long  readData


  long  page

  

PUB main

  Serial.start(31, 30, 0, 115200, 2)

  i2c.Initialize(I2C_SCL)


  serial.rxFlush

  readData := -1
  repeat until readData == 100
    readData := serial.rxCheck

  address := 0

   
  repeat page from 0 to 255

    serial.tx(page)

    ' fill the buffer
    repeat index from 0 to 127
      buffer[index] := serial.rx

    ' Write the buffer
    i2c.WritePage(I2C_SCL, EEPROMAddr, address, @buffer, 128)
    i2c.WriteWait(I2C_SCL, EEPROMAddr, address)
    waitcnt(cnt+5_000_000)

    ' report
'    serial.hex(address,4)
'    serial.tx(13)
      
    address += $80

  serial.str(string("Complete - Rebooting"))
  waitcnt(cnt+clkfreq)
  reboot
        
  