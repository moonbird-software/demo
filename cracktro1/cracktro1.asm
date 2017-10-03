;============================================================
;
;   CRACKTRO #1 - Finlandia
;
;   Copyright © 2016 Moonbird Software
;
;============================================================

!to "cracktro1.prg",cbm


;============================================================
;    constants
;============================================================

CODE_START = $0801
SID_START = $2000
SID_PLAY = $202e
SPRITE_START = $3fc0
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

          jsr init_screen
          jsr init_sprites
          jsr init_sid

          ldy #$7f
          sty $dc0d         ; disable CIA timer interrupts
          sty $dd0d
          lda $dc0d         ; cancel pending CIA interrupts
          lda $dd0d

          lda #$01          ; VIC interrupt on raster line
          sta $d01a

          lda #0            ; first irq on raster 0
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
          
          ldy #114          ; next irq on raster 114
          sty $d012
          
          lda #<irq_blue_border
          ldx #>irq_blue_border
          sta $314
          stx $315
          
          jmp $ea81         ; back to kernel irq

irq_blue_border
          nop               ; wait until raster starts
          nop
          nop
          nop
          nop
          nop
          
          dec $d019         ; irq ack
          
          ldy #$06          ; blue border
          sty $d020
          
          ldy #145          ; next irq on raster 145
          sty $d012
          
          lda #<irq_scroll
          ldx #>irq_scroll 
          sta $314
          stx $315
          
          jmp $ea81         ; back to kernel irq

irq_scroll 
          dec $d019         ; irq ack

          lda $d016         ; set smooth scroll
          and #$f8
          ora offset
          sta $d016

          ldy #154          ; next irq on raster 154
          sty $d012
          
          lda #<irq_noscroll
          ldx #>irq_noscroll 
          sta $314
          stx $315
          
          jmp $ea81         ; back to kernel irq

irq_noscroll           
          dec $d019         ; irq ack

          lda $d016         ; reset smooth scroll
          and #$f8
          sta $d016

          dec smooth
          bne continue

          dec offset
          bpl resetsmooth
          lda #7
          sta offset
  shiftrow
          ldx #00
          lda $5e1,x
          sta $5e0,x
          inx
          cpx #39
          bne shiftrow+2
          ldx nextchar      ; insert next character
          lda message, x
          ora #$80
          sta $607     
          inx
          lda message, x
          cmp #$00          ; loop message
          bne resetsmooth-3
          ldx #00
          stx nextchar
  resetsmooth
          ldx #1
          stx smooth
  continue  
          ldy #186          ; next irq on raster 186
          sty $d012
          
          lda #<irq_white_border
          ldx #>irq_white_border 
          sta $314
          stx $315

          jmp $ea81         ; back to kernel irq

irq_white_border
          nop               ; wait until raster starts
          nop
          nop
          nop
          nop
          nop
          
          dec $d019         ; irq ack
          
          ldy #$01          ; white border
          sty $d020

          ldy #249          ; next irq on raster 249
          sty $d012
          
          lda #<irq_bottom_border
          ldx #>irq_bottom_border
          sta $314
          stx $315
          
          jmp $ea81         ; back to kernel irq

irq_bottom_border
          dec $d019         ; irq ack
          
          lda $d011
          and #$f7
          sta $d011

          ldy #252          ; next irq on raster 252
          sty $d012
          
          lda #<irq_top_border
          ldx #>irq_top_border 
          sta $314
          stx $315   
          
          jmp $ea81         ; back to kernel irq

irq_top_border       
          dec $d019         ; irq ack
          
          lda $d011
          ora #$08
          sta $d011

          ldy #0            ; next irq on raster 0
          sty $d012
          
          lda #<irq_sid
          ldx #>irq_sid
          sta $314
          stx $315   

          jmp $ea81         ; back to kernel irq


;============================================================
;    initialize screen
;============================================================
           
init_screen 
          lda #$01          ; white screen
          sta $d020
          sta $d021
          
          lda $d016         ; 38 char mode to hide horizontal scrolling
          and #$f7
          sta $d016

          ldx #$00          ; clear screen
          lda #$20
  loop_clear
          sta SCREEN_START,x
          sta SCREEN_START+$100,x
          sta SCREEN_START+$200,x
          sta SCREEN_START+$300,x
          dex
          bne loop_clear

          ldx #$28          ; 40 characters wide
          
  loop_flag1     
          lda #$a0          ; inverted space
          sta SCREEN_START-1+8*40,x
          sta SCREEN_START-1+9*40,x
          sta SCREEN_START-1+10*40,x
          sta SCREEN_START-1+11*40,x
          sta SCREEN_START-1+12*40,x
          sta SCREEN_START-1+13*40,x
          sta SCREEN_START-1+14*40,x
          sta SCREEN_START-1+15*40,x
          sta SCREEN_START-1+16*40,x

          lda #$06          ; dark blue
          sta COLOR_START-1+8*40,x
          sta COLOR_START-1+9*40,x
          sta COLOR_START-1+10*40,x
          sta COLOR_START-1+11*40,x
          sta COLOR_START-1+12*40,x
          sta COLOR_START-1+13*40,x
          sta COLOR_START-1+14*40,x
          sta COLOR_START-1+15*40,x
          sta COLOR_START-1+16*40,x

          dex
          bne loop_flag1

          ldx #$08          ; 8 characters wide
          
  loop_flag2
          lda #$a0          ; inverted space
          sta SCREEN_START-1+0*40+9,x
          sta SCREEN_START-1+1*40+9,x
          sta SCREEN_START-1+2*40+9,x
          sta SCREEN_START-1+3*40+9,x
          sta SCREEN_START-1+4*40+9,x
          sta SCREEN_START-1+5*40+9,x
          sta SCREEN_START-1+6*40+9,x
          sta SCREEN_START-1+7*40+9,x
          sta SCREEN_START-1+17*40+9,x
          sta SCREEN_START-1+18*40+9,x
          sta SCREEN_START-1+19*40+9,x
          sta SCREEN_START-1+20*40+9,x
          sta SCREEN_START-1+21*40+9,x
          sta SCREEN_START-1+22*40+9,x
          sta SCREEN_START-1+23*40+9,x
          sta SCREEN_START-1+24*40+9,x
          
          lda #$06          ; dark blue
          sta COLOR_START-1+0*40+9,x
          sta COLOR_START-1+1*40+9,x
          sta COLOR_START-1+2*40+9,x
          sta COLOR_START-1+3*40+9,x
          sta COLOR_START-1+4*40+9,x
          sta COLOR_START-1+5*40+9,x
          sta COLOR_START-1+6*40+9,x
          sta COLOR_START-1+7*40+9,x
          sta COLOR_START-1+17*40+9,x
          sta COLOR_START-1+18*40+9,x
          sta COLOR_START-1+19*40+9,x
          sta COLOR_START-1+20*40+9,x
          sta COLOR_START-1+21*40+9,x
          sta COLOR_START-1+22*40+9,x
          sta COLOR_START-1+23*40+9,x
          sta COLOR_START-1+24*40+9,x
          
          dex
          bne loop_flag2

          rts


;============================================================
;    initialize sprites
;============================================================

init_sprites
          lda #$06        ; dark blue sprite
          sta $d027
          sta $d028
          sta $d029
          sta $d02a
          
          lda #8          ; sprite locations
          sta $d001
          sta $d003
          lda #96
          sta $d000
          sta $d004
          lda #112
          sta $d002
          sta $d006
          lda #240
          sta $d005
          sta $d007

          lda #SPRITE_START/$40  ; sprite pointers
          sta $07f8
          sta $07f9
          sta $07fa
          sta $07fb
         
          lda #$0f        ; sprites 00001111
          sta $d01d       ; double x
          sta $d017       ; double y    
          sta $d015       ; enable sprites
          
          rts


;============================================================
;    initialize SID
;============================================================

init_sid
          jsr SID_START
          
          rts


;============================================================
;    variables
;============================================================

offset    !byte $07
nextchar  !byte $00
smooth    !byte $01


;============================================================
;    static resources
;============================================================

message   !scr "!!! moonbird software is back on the scene in the year 2016 "
          !scr "!!! greets fly out to ironsoft, mwtc, dccdis, fairlight, razor "
          !scr "1911, yip (sorry for ripping off your fancy tune), and all of "
          !scr "you oldskool muthafuckas "
          !byte $00

* = SID_START
!bin "Megasound-editor.sid",, $7e

* = SPRITE_START
!byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
!byte  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
