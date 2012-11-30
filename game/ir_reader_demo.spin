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
        

        _irrpin         = 12     'ir receiver module on this pin
        _device         = 0     'accept any device code
        _dlyrpt         = 6     'delay before acception code as repeat

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
     byte screen[32]
     long block
OBJ

                                'select one rcvir and one term
                                
        rcvir   : "ir_reader_nec"
       ' rcvir   : "ir_reader_sony"

        'rcvir   : "ir_reader_rc5"
        term    : "serial_terminal"
        VGA     : "VGA_Text_Defcon.spin" 


PUB start | keycode, i

  
  term.start(30)                'start the tv terminal

    VGA.Start(VGA_BASE_PIN)

  'VGA.Str(string("Starting..")) 
  'VGA.Str(13)

  pause(5)
  

  rcvir.init(_irrpin,_device,_dlyrpt,true)   'startup

  block := 16
  
  if (cognew(updateScreen,0) == -1)
    VGA.str(string("Could not start thread"))
  
  
  repeat
    keycode := rcvir.fifo_get   'try a get from fifo
    if keycode == -1            'empty try again
      next
    if keycode & $80
      'term.out("R")             'show repeated code

      keycode := keycode & $7F

    'VGA.dec(keycode)         'show code
    if (keycode == 7)
      'VGA.Str(string("left"))
      term.str(string("Left"))
      block := block-1
      
    if (keycode == 9)
      'VGA.Str(string("right"))
      term.str(string("Right"))
      block := block +1
    
 
    
pub updateScreen | i

    pause(50)

    repeat i from 0 to 31
      if (block == i)
        VGA.dec(0)
      else
        VGA.dec(1)
      VGA.Str(13)
    
pub pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)
    