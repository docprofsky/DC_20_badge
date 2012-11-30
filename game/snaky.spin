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
  deathChar = "O"


  GAME_SPEED = 400
        
        
VAR
     byte screen[32*cols]
     byte objects[14]
     long blockA, BlockB, blockC, blockD,blockE
     long stack[90]
     long run
     long score
     long screenCog  
OBJ
                                'select one rcvir and one term
                                
        rcvir   : "ir_reader_nec"
        rr      : "realrandom"
        term    : "serial_terminal"
        VGA     : "VGA_Text_Defcon.spin" 

PUB start

  screenCog := 0
  'term.start(30)                'start the tv terminal

  VGA.Start(VGA_BASE_PIN)

  
  rr.start
  rcvir.init(_irrpin,_device,_dlyrpt,true)   'startup

  init  
  
  pause(5)

  'title
      
  main


pub title | i, keycode
i := 0
screen[5*32+13] := "P"
screen[5*32+14] := "Y"
screen[5*32+15] := "T"
screen[5*32+16] := "H"
screen[5*32+17] := "O"
screen[5*32+18] := "N"
screen[7*32+10] := "P"
screen[7*32+11] := "r"
screen[7*32+12] := "e"
screen[7*32+13] := "s"
screen[7*32+14] := "s"
screen[7*32+15] := " "
screen[7*32+16] := " "
screen[7*32+17] := "E"
screen[7*32+18] := "n"
screen[7*32+19] := "t"
screen[7*32+20] := "e"
screen[7*32+21] := "r"
screen[8*32+14] := "U"
screen[8*32+15] := "C"
screen[8*32+16] := "S"
screen[8*32+17] := "D"

'pause for start
repeat while (i == 0)
    keycode := rcvir.fifo_get   'try a get from fifo
    if keycode == -1            'empty try again
      next
    if keycode & $80
      keycode := keycode & $7F

    if (keycode == 8)
      i := 1

pub main | keycode, i

    screen[blockA+32*4] := snakeHead
    screen[blockB+32*3] := snakeChar
    screen[blockC+32*2] := snakeChar
    screen[blockD+32] := snakeChar
    screen[blockE] := snakeChar 

  repeat 'while (run == 1)

    keycode := rcvir.fifo_get   'try a get from fifo
    if keycode == -1            'empty try again
      next
    if keycode & $80
      keycode := keycode & $7F

    if (keycode == 6 and run == 0)
     init
     
    
    if (run == 1) 
      'reward player for being adventurous
      if (keycode == 7 and blockA > 1)
        'term.str(string("Left"))
        screen[blockA+32*4] := backgroundChar
        blockA := blockA-1
        score := score + 1
      elseif (keycode == 9 and blockA < 30)
        'term.str(string("Right"))
        screen[blockA+32*4] := backgroundChar                           
        blockA := blockA+1
        score := score + 1
            
      'update := 1
      
pub init | i
      
  blockA := 16
  blockB := 16
  blockC := 16
  blockD := 16
  blockE := 16

  score := 0
  run := 1

 repeat i from 0 to 32*cols-1
   if ((i //32 == 31 ) or (i //32 == 0))
      screen[i] := wallChar 
   else
      screen[i] := backgroundChar
 repeat i from 0 to cols-1
   objects[i] := 0


   if (screenCog == 0)
     screenCog := cognew(updateScreen,@stack[0])
   else
     coginit(screenCog,updateScreen,@stack[0])
 
pub updateScreen | i
  repeat while (run == 1)
    pause(GAME_SPEED)

    'if (update // 10 == 0)
      'scroll blocks
      repeat i from 0 to 13
      ' screen[32*(cols-i)+objects[i]] := backgroundChar
       ifnot (objects[i] == 0 or objects[i] == 31)
         screen[32*(i)+objects[i]] := backgroundChar
       
      
      repeat i from 0 to 12
        objects[i] := objects[i+1]
      objects[13] := rand
     
       screen[32*(13)+objects[13]] := objectChar
     
      repeat i from 0 to 12
        ifnot (objects[i] == 0 or objects[i] == 31) 
          screen[32*(i)+objects[i]] := objectChar 

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

      'increment score as time elapse
      score := score + 1
      'check for death, starting with head
      if (blockA == objects[4])
        screen[blockA+32*4] := deathChar
        run := 0
      elseif (blockB == objects[3])
        screen[blockB+32*3] := deathChar
        run := 0  
      elseif (blockC == objects[2])
        screen[blockC+32*2] := deathChar
        run := 0
      elseif (blockD == objects[1])
        screen[blockD+32*1] := deathChar
        run := 0
      elseif (blockE == objects[0])
        screen[blockE+32] := deathChar
        run := 0

     if (run == 0)
       displayGameOver 
       
    repeat i from 0 to 32*cols-1
       VGA.out(screen[i])
   
    'update := (update+1) // 10

pub displayGameOver | i
screen[6*32+11] := "G"
screen[6*32+12] := "A"
screen[6*32+13] := "M"
screen[6*32+14] := "E"
screen[6*32+15] := " "
screen[6*32+16] := " "
screen[6*32+17] := "O"
screen[6*32+18] := "V"
screen[6*32+19] := "E"
screen[6*32+20] := "R"

screen[7*32+11] := "S"
screen[7*32+12] := "C"
screen[7*32+13] := "O"
screen[7*32+14] := "R"
screen[7*32+15] := "E"
screen[7*32+16] := " "

'calcualte score diaply
i := score // 10
screen[7*32+20] := "0"+ i
score := score / 10
i := score // 10
screen[7*32+19] := "0"+ i
score := score / 10
i := score // 10
screen[7*32+18] := "0"+ i 
score := score / 10
i := score // 10
screen[7*32+17] := "0"+ i

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
    