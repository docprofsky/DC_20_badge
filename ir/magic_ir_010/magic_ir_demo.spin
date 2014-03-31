CON              
 _clkmode        = xtal1 + pll16x
 _xinfreq        = 5_000_000

  IRTX = 13                                                     ' ir led
  IRRX = 12                                                     ' ir demodulator
 
OBJ
 magicir : "magicir_010"
 
VAR
LONG code1[128], code1len
PUB main
magicir.storecode(IRRX, @code1, @code1len)

repeat
  magicir.playcode(IRTX,@code1,@code1len)
  waitcnt(clkfreq  + cnt)  

  