;============================================================
;
;   CRACKTRO #2 - Copper Bars
;
;   Copyright © 2017 Moonbird Software
;
;============================================================

!to "cracktro2.prg",cbm


;============================================================
;    constants
;============================================================

CODE_START = $0801
SID_START = $1035
SID_PLAY = $1038
SCREEN_START = $0400
COLOR_START = $d800


;============================================================
;    BASIC upstart
;============================================================

* = CODE_START 
          !word $080c
          !word $000a
          !byte $9e
          !text "2061"
          !byte $00
          !word $00


;============================================================
;    main program
;============================================================

          sei               ; disable interrupts

          jsr init_sid

          ldy #$7f
          sty $dc0d         ; disable CIA timer interrupts
          sty $dd0d
          lda $dc0d         ; cancel pending CIA interrupts
          lda $dd0d

          lda #$01          ; VIC interrupt on raster line
          sta $d01a

          lda #255            ; first irq on raster 0
          sta $d012
          lda $d011
          and #$7f
          sta $d011
          
          lda #<irq_sid
          ldx #>irq_sid 
          sta $314
          stx $315

          cli               ; enable interrupts

          jmp *             ; loop forever


;============================================================
;    raster interrupts
;============================================================

irq_sid
          dec $d019         ; irq ack
          
          jsr SID_PLAY      ; play that sick tune
          
          jmp $ea81         ; back to kernel irq


;============================================================
;    initialize SID
;============================================================

init_sid
          jsr SID_START
          
          rts


;============================================================
;    variables
;============================================================


;============================================================
;    static resources
;============================================================

* = SID_START
!bin "S-Express.sid",, $7e
