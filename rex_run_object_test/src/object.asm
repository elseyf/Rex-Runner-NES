;--------------------------------------------
; OBJECT MACROS
;--------------------------------------------
.SEGMENT "CODE"
;Struct for Objects:
.struct Object
   px        .word
   py        .word
   vx        .word
   vy        .word
   ax        .word
   ay        .word
   tiles_p   .word
   tiles_x_p .word
   tiles_y_p .word
   attr_p    .word
   size      .byte
.endstruct

;Set Object:
.MACRO set_object _obj, _x, _y, _w, _h, _tiles_p, _tiles_x_p, _tiles_y_p, _attr_p, _size
   ldm16 {_obj+Object::px}, {_x}
   ldm16 {_obj+Object::py}, {_y}
   ldm16 {_obj+Object::tiles_p}, {_tiles_p}
   ldm16 {_obj+Object::tiles_x_p}, {_tiles_x_p}
   ldm16 {_obj+Object::tiles_y_p}, {_tiles_y_p}
   ldm16 {_obj+Object::attr_p}, {_attr_p}
   ldm8  {_obj+Object::size}, {_size}
.ENDMACRO

;Copy Object:
.MACRO copy_object _obj1, _obj0
   ldm16 {_obj1+Object::px}, {_obj0+Object::px}
   ldm16 {_obj1+Object::py}, {_obj0+Object::py}
   ldm16 {_obj1+Object::tiles_p}, {_obj0+Object::tiles_p}
   ldm16 {_obj1+Object::tiles_x_p}, {_obj0+Object::tiles_x_p}
   ldm16 {_obj1+Object::tiles_y_p}, {_obj0+Object::tiles_y_p}
   ldm16 {_obj1+Object::attr_p}, {_obj0+Object::attr_p}
   ldm8  {_obj1+Object::size}, {_obj0+Object::size}
.ENDMACRO

;Copy Object to OAM:
.MACRO copy_to_oam_object _obj, _slot
.SCOPE
   ;Copy Object data to temp Object:
   copy_object {copy_obj}, {_obj}
   ;Calculate Slot to use:
   lda copy_obj+Object::size
   beq end
   .IF .MATCH(.LEFT(1,{_slot}),#)
      lda #.RIGHT(.TCOUNT({_slot})-1, {_slot})
   .ELSE
      lda _slot
   .ENDIF
   asl
   asl
   tax
   ldy #$00
   loop:
      ldm8 {oam_buffer,x}, {copy_obj+Object::py}
      add8 {oam_buffer,x}, {(copy_obj+Object::tiles_y_p),y}
      inx
      ldm8 {oam_buffer,x}, {(copy_obj+Object::tiles_p), y}
      inx
      ldm8 {oam_buffer,x}, {(copy_obj+Object::attr_p), y}
      inx
      ldm8 {oam_buffer,x}, {copy_obj+Object::px}
      add8 {oam_buffer,x}, {(copy_obj+Object::tiles_x_p), y}
      inx
      iny
      cpy copy_obj+Object::size
      bne loop
   end:
.ENDSCOPE
.ENDMACRO
