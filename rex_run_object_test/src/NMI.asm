;--------------------------------------------
.SEGMENT "CODE"
.PROC NMI
   pha
   txa
   pha
   tya
   pha
;-----------------------------------------------------
;Vblank dependent Updates:
;-----------------------------------------------------
;Sprite DMA from $0700 (sprite buffer)
   oam_dma oam_buffer
;Update Scroll Registers:
   set_scroll scroll_x, scroll_y
;Update Control Registers:
   set_PPU_CTRL R2000
   set_PPU_MASK R2001
;-----------------------------------------------------
;Non-Vblank dependent Updates:
;-----------------------------------------------------
;Read Controller:
   jsr read_controller
;Variable used to detect a passed frame:
   inc frame_inc
;Return:
   pla
   tay
   pla
   tax
   pla
rti
.ENDPROC
;--------------------------------------------
