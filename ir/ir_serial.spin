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


          'constant definitions for VGA screen manipulation functionality
  VGA_CLS       = $00           'clear screen
  VGA_HOME      = $01           'home
  VGA_BACKSPACE = $08           'backspace
  VGA_TAB       = $09           'tab (8 spaces per)
  VGA_SET_X     = $0A           'set X position (X follows)
  VGA_SET_Y     = $0B           'set Y position (Y follows)
  VGA_SET_COLOR = $0C           'set color (color follows)
  VGA_CR        = $0D           'carriage return

    'Propeller pin constant definitions.  Works with any Defcon 20 board.
  VGA_BASE_PIN  = 16
          
VAR
long stack[90]                    'Establish working space
       'LONG code1[128], code1len
       byte code1[513]
       long code1len
       byte code2[513]
       long code2len
OBJ

                                'select one rcvir and one term
                                
        'rcvir   : "ir_reader_nec"
        'rcvir   : "ir_reader_sony"

        term    : "FullDuplexSerial64"
        magicir : "magicir_010"     
        leds    : "jm_pwm8"
        VGA     : "VGA_Text_Defcon.spin" 

PUB start
  term.start(RX1, TX1, %0000, 57600)
  'leds.start(8, LED1)                                         ' start drivers

  'leds.set_all(0)
  'leds.set(7, $FF)

  VGA.Start(VGA_BASE_PIN)

  VGA.Str(string("Starting..")) 

  pause(5)

  cognew(IR_recv,@stack[0])
  cognew(IR_transmit,@stack[60])
  pause(10)
  VGA.Str(string(13))


PUB IR_recv | i, k
VGA.Str(string("R"))
repeat
    k := 0
    magicir.storecode(IRRX, @code1, @code1len)
    VGA.Str(string("Got IR:",13))    
    'leds.set(0, $FF)
    repeat i from 0 to 10
      VGA.hex(byte[code1[i]],2)
    VGA.Str(string(13))  

    repeat i from 0 to 511                 
      term.tx(byte[code1[i]])
      k := k+1
      'VGA.hex(byte[code1[i]],1)

    VGA.Str(string("sent:"))
    VGA.dec(k)
    VGA.Str(13)

      
    'code1len := 70

    VGA.Str(string("Len1:"))
    VGA.dec(code1len)
    VGA.Str(13)
    
    'VGA.Str(string("sending.",13)) 
    'magicir.playcode(IRTX,@code1,@code1len)
    'VGA.Str(string("done",13)) 

    'VGA.Str(string("Len2:"))
    'VGA.dec(code1len)
    'VGA.Str(13)
    
    
    pause(50)
    'leds.set(0, $00)
    
    pause(10)   


pub IR_transmit | i, k
VGA.Str(string("T"))
code2len := 70

repeat
   k := 0   
   repeat i from 0 to 511     
    code1[i] := term.rx
    VGA.Str(string("["))
    VGA.dec(k)
    VGA.Str(string("]"))
    k := k+1   
    'VGA.hex(byte[code1[i]],1) 
    'leds.set(1, $FF)
   'leds.set(1, $00)
   VGA.Str(string("Got serial:",13))
     repeat i from 0 to 10
      VGA.hex(byte[code2[i]],2)
    VGA.Str(string(13))  
   
   'leds.set(2, $FF)
     VGA.Str(string("sending.",13)) 
   magicir.playcode(IRTX,@code2,@code2len)
   VGA.Str(string("done",13))
   pause(50)
   'leds.set(2, $00)
    
   pause(10)
   
pub pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)

PUB nl
  term.tx(13)
  term.tx(10)