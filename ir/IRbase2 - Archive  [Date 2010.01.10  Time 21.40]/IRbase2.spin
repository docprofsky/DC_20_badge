CON
        _clkmode        = xtal1 + pll8x
        _xinfreq        = 10_000_000

        TVPinBase       = 12
        KeyPinBase      = 10
        SDPinBase       = 16
        
        IR_InPin        = 26
        IR_OutClockPin  = 25
        IR_OutPin       = 15
        IR_InMask       = |<IR_InPin
        IR_OutClockMask = |<IR_OutClockPin
        IR_OutMask      = |<IR_OutPin

obj
   tv: "TV_Text"
   kb: "keyboard"
   sd: "fsrw"

var
  long stack[200]
  long tstcount
  long sigBuffer[257]
  long end

  word scr_buf
  
  byte out
  byte fname[13]
  
pub main | timing, i, firstff, lastff, state, num

  kb.start( KeyPinBase+1, KeyPinBase)
  scr_buf := tv.start(TVPinBase)
  tv.str( string( "Please enter a filename (w/o ext):",13) )
  getFname
  tv.str( string( "Please select the key to record!!",13) )
  sd.mount( SDPinBase )
  sd.popen( @fname[0],"w" ) 

  out:="1"
  ' don't start measurement automatically, it'll be started by
  ' print later on
  sigBuffer[0]:=0

  ' hmmm ... of course it does not need to run in a different COG
  ' just old code which survived ;o)
  cognew(print, @stack[0] )
  ' this starts the PASM code that measures the IR signal and also can
  ' playback
  cognew(@ir_rec, @sigBuffer )

  ' wait until print is exited by pushing space
  repeat until end

  ' old code ....
  'cognew(@ir_out, 0 )
  'cognew(outHiLo, @stack[50] )
  'repeat
  
{{
  timing := cnt
  repeat until end

    timing += 10000
    waitcnt( timing )
    if ina[ IR_InPin ]
      out:="1"
    else
      out:="0"
}}

  ' measurement done, so close the file and start replay 
  sd.pclose
  tv.out( 0 )
  tv.str( string( "done!" ))

  ' first seek for the end of a sequence (currently identified
  ' by 1s for at least 5 longs
  state:=0
  ' loop over all samples and find the end of one sequence, the rest is overwritten
  ' with 1s (loop could also be stopped when in state 2 - but I did not remember the
  ' break instruction ;o). The long which switched to state 2 should be overwritten
  ' as it contains 0s.
  repeat i from 1 to 256
    if state==0
      if sigBuffer[i]==$ffff_ffff
        state:=1
        firstff:=i
    if state==1
      if sigBuffer[i]==$ffff_ffff
        lastff:=i
      else
        if lastff-firstff>5
          state:=2
    if state==2
      sigBuffer[i]:=$ffff_ffff
      
  timing := 0
  ' start the carrier frequency-COG
  cognew(@ir_out, 0 )
  ' and replay the signal up to the end found above
  repeat
    tv.str( string( $a,3,$b,3,"sending ... " ))
    tv.dec( timing++ )
    repeat while sigBuffer[0]
    ' 2 = command for sending, higher byte tells how much
    sigBuffer[0]:=2 + lastff<<8

' awaits the filename to be entered with keyboard but without extension.
' CR or entering 8 characters ends the input.
pub getFname | i,done,pos
  pos:=0
  done:=0
  repeat until done
    i:=kb.getkey
    if i==13
      done:=1
    else
      fname[pos++]:=i
      tv.out( i )
      if pos==8
        done:=1
  fname[pos++]:="."
  fname[pos++]:="t"
  fname[pos++]:="x"
  fname[pos++]:="t"
  fname[pos++]:=0
  tv.str( string(".txt") )
  tv.out( 13 )
  
pub print | in
' old version which was written in SPIN-only
{{
  repeat
    tv.out( 0 )
    tv.str( string("IR Test ") )
    tv.dec( tstcount++ )
    tv.out( 13 )
    waitpne( IR_InMask,IR_InMask,0 )
    repeat 440
      tv.out( out )
    in:=kb.getkey
}}

  ' repeat until SPACE has been entered
  repeat
    in:=0
            
    ' get the name of the key pressed and write it to file
    repeat until in==13
      in:=kb.getkey
      if in==" "
        end:=1
        return
      if in <> 13
        sd.pputc( in )

    sd.pputc( ":" )
    sd.pputc( $0d )
    sd.pputc( $0a )

    ' start the measurement and wait until COG filled the buffer
    sigBuffer[0]:=1    
    repeat while sigBuffer[0]

    ' write the buffer to screen in HEX and to file as "bitstream"
    tv.out( 0 )
    tv.str( string("IR Test ") )
    tv.dec( tstcount++ )
    tv.out( 13 )
    'waitpne( IR_InMask,IR_InMask,0 )
    repeat in from 1 to 256
      tv.hex( sigBuffer[in], 8 )
      tv.out(" ")
      fileOut( sigBuffer[in] )
    sd.pputc( $0d )
    sd.pputc( $0a )

pub fileOut( val )
  repeat 32
    if val&$80000000
      sd.pputc( "1" )
    else
      sd.pputc( "0" )
    val<<=1
  sd.pputc( $0d )
  sd.pputc( $0a )
    
pub outHiLo | tim2
  dira[IR_OutPin]:=1

  repeat
    tim2:=cnt
    repeat 20
      tim2 += 80_000
      waitcnt( tim2 )
      !outa[ IR_OutPin ]
    outa[ IR_OutPin ]:=0
    waitcnt( clkfreq+cnt )  
    
' This one generates the ~33kHz carrier signal.
' Maybe a counter can do the job later on.
dat
  org 0

tim
ir_out        or        dira, ir_clk_mask
              mov       tim, cnt
              add       tim, ir_wait

da_lp         waitcnt   tim, ir_wait
              xor       outa, ir_clk_mask
              jmp       #da_lp

ir_clk_mask   long      IR_OutClockMask
ir_wait       long      80_000_000 / 33_000 / 2


' measure- and replay-code
dat
        org 0

ir_rec        rdlong    ir_smpl_buf, par WZ
        if_z  jmp       #ir_rec

              mov       cur, ir_smpl_buf
              and       cur, #$ff

              cmp       cur, #1 WZ
        if_z  jmp       #read
              cmp       cur, #2 WZ
        if_z  jmp       #send
              wrlong    zero, par
              jmp       #ir_rec
read
              movd      store, #ir_smpl_buf

              waitpeq   ir_in_mask, ir_in_mask
              waitpne   ir_in_mask, ir_in_mask
              mov       bitcnt, #32
              mov       longcnt, #256
              test      ir_in_mask, ina WC
        if_c  jmp       #read
        
              mov       tcnt, cnt
              add       tcnt, ir_smpl_time
              jmp       #rollin

lp            mov       bitcnt, #32
lp2           waitcnt   tcnt, ir_smpl_time
              test      ir_in_mask,ina WC
rollin        rcl       cur, #1

              djnz      bitcnt, #lp2
store         mov       0-0,cur
              add       store, wroffset

              djnz      longcnt, #lp

              mov       longcnt, #256
              movd      wrlo, #ir_smpl_buf
              mov       wradr, par
              add       wradr, #4
wrlo
              wrlong    ir_smpl_time, wradr
              add       wradr, #4
              add       wrlo, wroffset
              djnz      longcnt, #wrlo

              wrlong    zero, par
              jmp       #ir_rec

send
              or        dira, ir_out_mask
                            
              mov       sendcnt, ir_smpl_buf
              shr       sendcnt, #8
              mov       longcnt, sendcnt

              movd      sndlo, #ir_smpl_buf
              mov       wradr, par
              add       wradr, #4
sndlo
              rdlong    0-0, wradr
              add       wradr, #4
              add       sndlo, wroffset
              djnz      longcnt, #sndlo

lddone
              movs      load, #ir_smpl_buf
              mov       tcnt, cnt
              add       tcnt, ir_smpl_time
              mov       longcnt, sendcnt

load          mov       cur, 0-0

slp           mov       bitcnt, #32
slp2          rcl       cur, #1 WC
              waitcnt   tcnt, ir_smpl_time
      if_c    or        outa, ir_out_mask
      if_nc   andn      outa, ir_out_mask

              djnz      bitcnt, #slp2
              add       load, #1
              djnz      longcnt, #load

              andn      dira, ir_out_mask
              wrlong    zero, par
              jmp       #ir_rec
              
cur           long      1
bitcnt        long      0
tcnt          long      0
longcnt       long      0
sendcnt       long      0
wradr         long      0
zero          long      0         
ir_in_mask    long      IR_InMask
ir_out_mask   long      IR_OutMask
ir_smpl_time  long      4_000
wroffset      long      %1000000000
ir_smpl_buf   long      0 [256]

              fit       492                         