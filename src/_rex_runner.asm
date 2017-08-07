;--------------------------------------------
; Rex Runner for NES
; Code by el_seyf
; Graphics by FrankenGraphics
;--------------------------------------------
.OUT .SPRINTF("--------------------------------------------")
;--------------------------------------------
; INCLUDES:
;--------------------------------------------
   ;Header:
   .include "header.asm"
   
   ;Defines:
   .include "defines.asm"
   
   ;Macros:
   .include "macros.asm"
   .include "math16_macros.asm"
   .include "rect.asm"
   .include "object.asm"
   .include "camera.asm"
;--------------------------------------------
; VARIABLES:
;--------------------------------------------
.SEGMENT "ZEROPAGE": zeropage
;Keep ZeroPage start to calculate Usage:
zp_start = *
;Register Shadows (written to Registers in NMI):
   R2000:      .res 1
   R2001:      .res 1
   scroll_x:   .res 2
   scroll_y:   .res 1
;Store Controller State:
   _pad:       .res 1
   _pad_last:  .res 1
;Variable used to detect passed frame:
   frame_inc:  .res 1
;Math16 Macro Variables:
   arith_a:       .res 2
   arith_b:       .res 2
   mult_result:   .res 2
   div_result:    .res 2
   mod_result:    .res 2
;General Purpose Pointer:
   pointer:       .res 2
;Random Number Genreator Variables:
   SEED0:         .res 1
   SEED1:         .res 1
   SEED2:         .res 1
   SEED3:         .res 1
   TMP:           .res 1
;Ingame ZP-Variables:
   object_p:      .res 2
   copy_obj:      .tag Object
   
   
;Keep ZeroPage end to calculate Usage:
zp_end = *
;--------------------------------------------
.SEGMENT "STACK"
   stack:      .res 256
.SEGMENT "OAM_BUFFER"
   oam_buffer: .res 256
.SEGMENT "BSS"
ram_start = *
;Macro Temp Stack:
   macro_temp_p:  .res 1
   macro_temp:    .res 16

;Ingame Variables:
   update_bg_flag:   .res 1
   camera:        .tag Camera
   rex_obj:       .tag Object
   dummy_obj:     .tag Object
   
   
   vram_instruction_buffer:   .res 512
ram_end = *
;--------------------------------------------
; CODE:
;--------------------------------------------
.SEGMENT "CODE"
code_start = *
.PROC rex_runner_begin
   ;Reset VRAM Instruction Buffer (write RTS to first Instruction):
   ldm8 vram_instruction_buffer, #$60
   
   ;Transfer Palette and Tiles:
   write_pal palette_rex_bg, 16, #$00
   write_pal palette_rex_bg, 16, #$10
   write_chr #tile_data_begin, #tile_data_end, #$0000
   write_chr #rex_tile_data_begin, #rex_tile_data_end, #$1000
   
   ;Draw Background:
   set_PPU_ADDR #$2100
   ldx #0
   lda #'a'
   @loop:
      sta $2007
      inx
      cpx #32
      bne @loop
   
   set_object rex_obj, #50, #100, #8*6, #8*4, #rex_tiles, #rex_tiles_x, #rex_tiles_y, #rex_attr, #14
   copy_object dummy_obj, rex_obj

   set_follow_object_camera camera, #rex_obj
   offset_camera camera, #-127, #0

   ;Enable NMI and Rendering, use VRAM $1000 for Sprites:
   set_PPU_CTRL #$88
   set_PPU_MASK #$1E
   
   jmp main
.ENDPROC
;--------------------------------------------
; CODE INCLUDES:
;--------------------------------------------
   .include "RESET.asm"
   .include "NMI.asm"
   .include "read_controller.asm"
   .include "main.asm"
   .include "rand.asm"
;--------------------------------------------
; DATA:
;--------------------------------------------
.SEGMENT "CODE"
palette_rex_bg:
   .BYTE $2C, $2A, $19, $38
   .BYTE $2C, $2A, $19, $38
   .BYTE $2C, $2A, $19, $38
   .BYTE $2C, $2A, $19, $38
palette_rex_sprite:
   .BYTE $2C, $2A, $19, $38
   .BYTE $2C, $2A, $19, $38
   .BYTE $2C, $2A, $19, $38
   .BYTE $2C, $2A, $19, $38
   
rex_tiles:
   .BYTE $04, $05, $12, $13, $14, $15, $20, $21, $22, $23, $24, $31, $32, $33
rex_tiles_x:
   .BYTE 32, 40, 16, 24, 32, 40, 0, 8, 16, 24, 32, 8, 16, 24
rex_tiles_y:
   .BYTE 0, 0, 8, 8, 8, 8, 16, 16, 16, 16, 16, 24, 24, 24
rex_attr:
   .BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
   
overlap_text:
   .BYTE $40, $41, $42, $43, $44, $45, $46
overlap_text_x:
   .BYTE 0, 8, 16, 24, 32, 40, 48
overlap_text_y:
   .BYTE 0, 0, 0, 0, 0, 0, 0
overlap_text_attr:
   .BYTE 0, 0, 0, 0, 0, 0, 0
   
   
   
code_end = *
;--------------------------------------------
;Add CHRROM:
.SEGMENT "CHRROM"
chr_start = *
;Tile Data:
   tile_data_begin:
      .incbin "tiles.chr"
   tile_data_end:
;Rex Tile Data:
   rex_tile_data_begin:
      .incbin "trex_sprite.chr"
   rex_tile_data_end:
   
chr_end = *
;--------------------------------------------
;Add Vectors:
   .include "vectors.asm"
;--------------------------------------------
.OUT .SPRINTF("--------------------------------------------")
;Output ZeroPage Usage:
.OUT .SPRINTF("ZeroPage Usage:%c%d Bytes", 9, zp_end-zp_start)
;Output RAM Usage:
.OUT .SPRINTF("RAM Usage:%c%c%d Bytes", 9, 9, 768+(ram_end-ram_start))
;Print Code Usage:
.OUT .SPRINTF("Code Usage:%c%c%d Bytes", 9, 9, code_end-code_start)
;Output Total Usage:
.OUT .SPRINTF("Total Usage:%c%c%d Bytes", 9, 9, (chr_end-chr_start)+(code_end-code_start))
;Output Free Space:
.OUT .SPRINTF("Free:%c%c%c%d Bytes", 9, 9, 9, 16384-((chr_end-chr_start)+(code_end-code_start)))
.OUT .SPRINTF("--------------------------------------------")
