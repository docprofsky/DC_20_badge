var

  long  cog                                                     ' cog id

  long  irframes                                                ' frames ( > 0 is flag to tx )     
  long  ircode                                                  ' code
  long  irbits                                                  ' bits in ir code
  long  irstart                                                 ' ticks in start bit
  long  irbiton
  long  irticks


pub start(pin, hz)

'' Starts samsung cog if cog available
'' -- pin is IR LED cathode
'' -- hz is modulation frequency (e.g., 40_000)

  stop                                                          ' stop if running

  if ((pin => 0) and (pin =< 27))                               ' protect rx, tx, i2c

    ' convert frequency for counter NCO mode
     
    hz := clkfreq / hz
    hz := ($8000_0000 / hz) << 1
     
    ' setup parameters for cog
     
    irframes := pin
    ircode   := hz
    irbits   := clkfreq / 10_000 * 778                            ' frame timing
    irstart  := clkfreq / 1_000_000 * 4_500                     ' ticks in 4.5ms
    irbiton  := clkfreq / 1_000_000 * 1_500                      ' ticks in 1.5ms
    irticks  := clkfreq / 1_000_000 * 650                        ' ticks in 650us
     
    cog := cognew(@txsam, @irframes) + 1                      ' start cog
    if (cog)                                                    ' if successful
      waitcnt(cnt + (clkfreq >> 10))                            ' wait about 1ms     

  return cog


pub stop

'' Stops IR cog if running

  if (cog)
    cogstop(cog - 1)
    cog := 0
    

pub tx(code, frames)

'' Transmits samsung code
'' -- code is the code to transmit
'' -- frames is the number of transmitted frames (typically 3 to 5)

  if (frames > 0)
    ircode   := code
    irbits := 32
    irframes :=  1 #> frames <# 5                               ' limit frames
    


pub busy

'' Reports returns true while code is transmitting

  return (irframes > 0)


dat

                        org     0

txsam                   mov     t1, par                         ' start of parameters
                        rdlong  txpin, t1                       ' read tx pin
                        mov     txmask, #1                      ' create pin control mask
                        shl     txmask, txpin
                        mov     outa, txmask                    ' disable ir
                        mov     dira, txmask

                        add     t1, #4                          ' get mod frequency
                        rdlong  frqa, t1                        ' setup ctra for txpin
                        movs    ctra, txpin
                        movi    ctra, NCO_SE

                        add     t1, #4
                        rdlong  frametix, t1                    ' read ticks in 68.8 ms frame

                        add     t1, #4
                        rdlong  starttix, t1                    ' read ticks in start bit (4.5ms)

                        add     t1, #4
                        rdlong  bit1tix, t1

                        add     t1, #4
                        rdlong  bit0tix, t1

                        wrlong  ZERO, par                       ' clear frame count

                        
waitcmd                 mov     t1, par                         ' address of parameters
                        rdlong  txframes, t1            wz      ' get frame count
        if_z            jmp     #waitcmd                        ' wait for non-zero

                        add     t1, #4
                        rdlong  txcode, t1                      ' read code to tx

                        add     t1, #4
                        rdlong  txbits, t1                      ' read bits to tx

startframe              mov     frametimer, frametix            ' start the frame timer
                        add     frametimer, cnt

txstart                 mov     basetimer, starttix
                        add     basetimer, cnt                   ' sync with system coutner
                        andn    outa, txmask                    ' enable modulation
                        waitcnt basetimer, starttix               ' wait, then load bit pad (0)
                        or      outa, txmask                    ' make sure it's off
                        waitcnt basetimer, #0                    ' let pad timing expire


                        mov     outcode, txcode                 ' copy code  
                        mov     outbits, txbits                 ' copy bit count

txir                    rcr     outcode, #1             wc      ' get lsb --> C
        if_c            mov     bittimer, bit1tix               
        if_nc           mov     bittimer, bit0tix
                        call    #txbit
                        djnz    outbits, #txir                  ' all bits tx'd?

                        'waitcnt frametimer, frametix            ' let frame timer expire
                        djnz    txframes, #txstart              ' start next frame

                        wrlong  ZERO, par                       ' alert hub
                        jmp     #waitcmd

                        
' load bittimer with ticks before calling                     
                                           
txbit                   mov     basetimer, bit0tix
                        add     basetimer, cnt                   ' sync with system counter
                        andn    outa, txmask                    ' enable modulation
                        waitcnt basetimer, bittimer               ' wait, then load bit pad (0)
                        or      outa, txmask                    ' make sure it's off
                        waitcnt basetimer, #0                    ' let pad timing expire
txbit_ret               ret   

' --------------------------------------------------------------------------------------------------

ZERO                    long    0
NCO_SE                  long    %00100_000                      ' counter NCO mode (for movi)

txpin                   res     1                               ' ir tx pin (cathode)
txmask                  res     1                               ' mask for tx pin
frametix                res     1                               ' ticks in 45ms frame
starttix                res     1                               ' ticks in 2.4ms start bit
bit1tix                 res     1                               ' ticks in 1.2ms "1" bit
bit0tix                 res     1                               ' ticks in 0.6ms "0" bit
basetimer               res     1

txframes                res     1                               ' command parameters
txcode                  res     1
txbits                  res     1

frametimer              res     1                               ' timers
bittimer                res     1

outcode                 res     1                               ' working copy of code
outbits                 res     1                               ' bits in code

t1                      res     1                               ' work vars
t2                      res     1

                        fit     496
                        

dat

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}             