;
; first_nes
; lib/isr/vertical_blank.s
;
; After the NES displays a frame of graphics, it stops drawing for a while. This period is known
; as the vertical blank, or "vblank", and is a good choice for performing graphics updates. Note
; that this interrupt is non-maskable (NMI).
;
; Written by Greg M. Krsak <greg.krsak@gmail.com>, 2018
;
; Based on the NintendoAge "Nerdy Nights" tutorials, by bunnyboy:
;   http://nintendoage.com/forum/messageview.cfm?catid=22&threadid=7155
; Based on "Nintendo Entertainment System Architecture", by Marat Fayzullin:
;   http://fms.komkon.org/EMUL8/NES.html
; Based on "Nintendo Entertainment System Documentation", by an unknown author:
;   https://emu-docs.org/NES/nestech.txt
;
; Processor: 8-bit, Ricoh RP2A03 (6502), 1.789773 MHz (NTSC)
; Assembler: ca65 (cc65 binutils)
;
; Tested with:
;  ca65 first_nes.s
;  ld65 first_nes.o -C config/ines.cfg
;  cat bin/first_nes_hdr.bin bin/first_nes_prg.bin bin/first_nes_chr.bin > first_nes.nes
;  rm a.out && rm first_nes.o
;  nestopia first_nes.nes
;
; Tested on:
;  Nestopia UE 1.47
;
; For more information about NES programming in general, try these references:
; https://en.wikibooks.org/wiki/NES_Programming
;
; For more information on the ca65 assembler, try these references:
; https://github.com/cc65/cc65
; http://cc65.github.io/doc/ca65.html
;


.PROC ISR_Vertical_Blank
    lda     #$00
    sta     _OAMADDR                ; Set the low byte (00) of the RAM address
    lda     #$02
    sta     _OAMDMA                 ; Set the high byte (02) of the RAM address, start the transfer

  ; Freeze the button positions
  latchControllerBegin:
    lda     #$01
    sta     _JOY1
    lda     #$00
    sta     _JOY1                   ; Tell both the controllers to latch buttons
  
  ; Check button A
  readButtonABegin: 
    lda     _JOY1                    
    and     #%00000001              ; Only look at bit 0
    beq     readButtonAEnd          ; Branch to readButtonAEnd if button A is NOT pressed (0)                                    
    jsr     MoveMarioRight          ; Jump to the subroutine that moves the Mario sprites right
  readButtonAEnd:

  ; Check button B
  readButtonBBegin: 
    lda     _JOY1                    
    and     #%00000001              ; Only look at bit 0
    beq     readButtonBEnd          ; Branch to readButtonBEnd if button B is NOT pressed (0)                                    
    jsr     MoveMarioLeft           ; Jump to the subroutine that moves the Mario sprites left
  readButtonBEnd:
  
    rti                             ; Return from interrupt 
.ENDPROC


; End of lib/isr/vertical_blank.s