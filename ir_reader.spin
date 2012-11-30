{{ ir_reader_demo.spin

  Bob Belleville

  This object receives input from an IR remote using
  object ir_reader_nec.spin or ir_reader_sony.spin.

  This is a good tool to use to build a table showing
  the key code for each button.

  see readme.pdf for more documentaton

  2007/03/01 - derived from ir_reader_nec_show.spen
               and tv_terminal_demo.spin
  2007/03/03 - generalized for nec and sony objects
               provide method to get device ID
               

}}

CON

                                'will NOT work at other speeds
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

        CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq   
        MS_001   = CLK_FREQ / 1_000
        US_001   = CLK_FREQ / 1_000_000

        RX1  = 31                                                     ' programming / terminal
        TX1  = 30
        
        IRTX = 13                                                     ' ir led
        IRRX = 12                                                     ' ir demodulator

        LED8 = 23                                                     ' leds / vga
        LED7 = 22
        LED6 = 21
        LED5 = 20
        LED4 = 19
        LED3 = 18
        LED2 = 17
        LED1 = 16
        
          
VAR
       'LONG code1[128], code1len
       byte code1[512]
       long code1len
OBJ

                                'select one rcvir and one term
                                
        'rcvir   : "ir_reader_nec"
        'rcvir   : "ir_reader_sony"

        term    : "FullDuplexSerial64"
        magicir : "magicir_010"     
        leds    : "jm_pwm8"

PUB start | i 
  term.start(RX1, TX1, %0000, 57600)
  leds.start(8, LED1)                                         ' start drivers

  leds.set_all(0)
  leds.set(7, $FF)

  pause(5)


 
    magicir.storecode(IRRX, @code1, @code1len)
repeat     
    leds.set(0, $FF) 
    term.str(string("codeLen:"))
    term.dec(code1len)
    nl

    'term.str(string("code:"))
    'nl
    'repeat i from 0 to 512                 
      'term.tx(byte[code1[i]])
    code1len := 70 
    
    magicir.playcode(IRTX,@code1,@code1len) 

    nl
    pause(50)
    leds.set(0, $00)
    pause(50)   


PUB nl
  term.tx(13)
  term.tx(10)

pub recive | i
   repeat i from 0 to 512     
    code1[i] := term.rx
   magicir.playcode(IRTX,@code1,@code1len)
   
pub pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)
    
