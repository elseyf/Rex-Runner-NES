;--------------------------------------------
; Object Test for NES, by el_seyf
;--------------------------------------------
; INCLUDES:
;--------------------------------------------
   ;Header:
   .include "header.asm"
   
   ;Defines:
   .include "defines.asm"
   
   ;Macros:
   .include "macros.asm"
   .include "object.asm"
;--------------------------------------------
; VARIABLES:
;--------------------------------------------
.SEGMENT "ZEROPAGE": zeropage
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
;General Purpose Pointer:
   pointer:       .res 2
   
;Ingame ZP-Variables:
   object_p:      .res 2
   copy_obj:      .tag Object
   
   
;--------------------------------------------
.SEGMENT "STACK"
   stack:      .res 256
.SEGMENT "OAM_BUFFER"
   oam_buffer: .res 256
.SEGMENT "BSS"
;Macro Temp Stack:
   macro_temp_p:  .res 1
   macro_temp:    .res 16

;Ingame Variables:
   test_obj:     .tag Object
   test_obj_frame_counter: .res 1
;--------------------------------------------
; CODE:
;--------------------------------------------
.SEGMENT "CODE"
.PROC rex_runner_begin
   ;Transfer Palette and Tiles:
   write_pal palette_rex_bg, 16, #$00
   write_pal palette_rex_sprite, 16, #$10
   write_chr #rex_tile_data_begin, #rex_tile_data_end, #$1000
   
   set_object test_obj, #50, #100, #8*6, #8*4, #rex_frame_0_tiles, #rex_frame_0_tiles_x, #rex_frame_0_tiles_y, #rex_frame_0_attr, rex_frame_0_size

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
   .include "rex_animation.asm"
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
   
;--------------------------------------------
;Add CHRROM:
.SEGMENT "CHRROM"
;Rex Tile Data:
   rex_tile_data_begin:
      .incbin "trex_sprite.chr"
   rex_tile_data_end:
   
;--------------------------------------------
;Add Vectors:
   .include "vectors.asm"
;--------------------------------------------
