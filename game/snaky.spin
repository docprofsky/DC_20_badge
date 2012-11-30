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

  cols = 14

  backgroundChar = " "
  snakeChar = "#"
  snakeHead = "V"
  wallChar = "|"
  objectChar = "X"


  GAME_SPEED = 400

  

        
        
VAR
     byte screen[32*cols]
     byte objects[14]
     long blockA, BlockB, blockC, blockD,blockE
     long stack[90]
     long update 
OBJ

                                'select one rcvir and one term
                                
        rcvir   : "ir_reader_nec"
        rr      : "realrandom"
        term    : "serial_terminal"
        VGA     : "VGA_Text_Defcon.spin" 


PUB start | keycode, i

  
  'term.start(30)                'start the tv terminal

  VGA.Start(VGA_BASE_PIN)

  
  rr.start
  rcvir.init(_irrpin,_device,_dlyrpt,true)   'startup

  blockA := 16
  blockB := 16
  blockC := 16
  blockD := 16
  blockE := 16


  'update := 1
  
  pause(5)

  init
  
  if (cognew(updateScreen,@stack[0]) == -1)
    VGA.Str(string("Could not start thread"))

    screen[blockA+32*4] := snakeHead
    screen[blockB+32*3] := snakeChar
    screen[blockC+32*2] := snakeChar
    screen[blockD+32] := snakeChar
    screen[blockE] := snakeChar 

  repeat

    keycode := rcvir.fifo_get   'try a get from fifo
    if keycode == -1            'empty try again
      next
    if keycode & $80
      keycode := keycode & $7F


    if (keycode == 7 and blockA > 1)
      'term.str(string("Left"))
      screen[blockA+32*4] := backgroundChar
      blockA := blockA-1
    elseif (keycode == 9 and blockA < 30)
      'term.str(string("Right"))
      screen[blockA+32*4] := backgroundChar                           
      blockA := blockA+1
    'update := 1

  'end
  rr.stop
  VGA.stop
   
pub init | i
 repeat i from 0 to 32*cols-1
   if ((i //32 == 31 ) or (i //32 == 0))
      screen[i] := wallChar 
   else
      screen[i] := backgroundChar
 repeat i from 0 to cols-1
   objects[i] := 0
 
pub updateScreen | i
  repeat
    pause(GAME_SPEED)

    'scroll blocks
    'repeat i from 0 to 12
    ' screen[32*(cols-i)+objects[i]] := backgroundChar
    ifnot (objects[13] == 0 or objects[13] == 31)
      screen[32*(13)+objects[13]] := backgroundChar
    
    
    repeat i from 0 to 12
      objects[i] := objects[i+1]
    objects[13] := rand

     screen[32*(13)+objects[13]] := objectChar

    'repeat i from 0 to 13
    ' screen[32*(cols-i)+objects[i]] := objectChar 

   
  'if (update > 0)
    screen[blockA+32*4] := backgroundChar
    screen[blockB+32*3] := backgroundChar
    screen[blockC+32*2] := backgroundChar
    screen[blockD+32] := backgroundChar
    screen[blockE] := backgroundChar 
     
    blockE := blockD
    blockD := blockC
    blockC := blockB
    blockB := blockA
      
    screen[blockA+32*4] := snakeHead
    screen[blockB+32*3] := snakeChar
    screen[blockC+32*2] := snakeChar
    screen[blockD+32] := snakeChar
    screen[blockE] := snakeChar 
     
     
     repeat i from 0 to 32*cols-1
        VGA.out(screen[i])
       
      'update := (update+1) // 6



pub rand
return ((||rr.random) // 30)+1 
      
pub pause(ms) | t

'' Delay program in milliseconds
'' -- use only in full-speed mode 

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1792                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)
    