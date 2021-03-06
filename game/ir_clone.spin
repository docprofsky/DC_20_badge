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
        _device         = 0     'accept any device code
        _dlyrpt         = 6     'delay before acception code as repeat   
        
          
VAR

OBJ

                                'select one rcvir and one term
                                
        rcvir   : "ir_reader_rc5"
        VGA     : "VGA_Text_Defcon.spin" 

PUB start | keycode
  VGA.Start(VGA_BASE_PIN)

  VGA.Str(string("Starting..")) 

  pause(5)


  
  rcvir.init(RX1,_device,_dlyrpt,true)   'startup
  
  repeat
    keycode := rcvir.fifo_get   'try a get from fifo
    if keycode == -1
       VGA.Str(String("N"))            'empty try again
      next
    if keycode & $80
      VGA.Str(String("R"))             'show repeated code
      VGA.dec(keycode & $7F)
    else
      VGA.dec(keycode)         'show code
    'sp
                                'device code is in low 16 bits
    'term.hex(rcvir.fifo_get_lastvalid,8)


  

repeat     
 

pub pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)
    