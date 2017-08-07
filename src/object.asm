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
   bounds    .tag Rect
   tiles_p   .word
   tiles_x_p .word
   tiles_y_p .word
   attr_p    .word
   size      .byte
.endstruct

;Defines:
.define OBJECT_VX_SHIFT 5
OBJECT_MAX_VX   = 32<<OBJECT_VX_SHIFT
.define OBJECT_VY_SHIFT 3
OBJECT_MAX_VY   = 32<<OBJECT_VY_SHIFT

;Set Object:
.MACRO set_object _obj, _x, _y, _w, _h, _tiles_p, _tiles_x_p, _tiles_y_p, _attr_p, _size
   ldm16 {_obj+Object::px}, {_x}
   ldm16 {_obj+Object::py}, {_y}
   set_rect {_obj+Object::bounds}, {_x}, {_y}, {_x}, {_y}
   add16 {_obj+Object::bounds+Rect::right}, {_w}
   add16 {_obj+Object::bounds+Rect::bottom}, {_h}
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
   copy_rect {_obj1+Object::bounds}, {_obj0+Object::bounds}
   ldm16 {_obj1+Object::tiles_p}, {_obj0+Object::tiles_p}
   ldm16 {_obj1+Object::tiles_x_p}, {_obj0+Object::tiles_x_p}
   ldm16 {_obj1+Object::tiles_y_p}, {_obj0+Object::tiles_y_p}
   ldm16 {_obj1+Object::attr_p}, {_obj0+Object::attr_p}
   ldm8  {_obj1+Object::size}, {_obj0+Object::size}
.ENDMACRO

;Move Object:
.MACRO moveX_object _obj, _dx
   add16 {_obj+Object::px}, {_dx}
   moveX_rect {_obj+Object::bounds}, {_dx}
.ENDMACRO

.MACRO moveY_object _obj, _dy
   add16 {_obj+Object::py}, {_dy}
   moveY_rect {_obj+Object::bounds}, {_dy}
.ENDMACRO

.MACRO move_object _obj, _dx, _dy
   moveX_object {_obj}, {_dx}
   moveY_object {_obj}, {_dy}
.ENDMACRO

;Move Object to specific Location:
.MACRO moveToX_object _obj, _px
   ldm16 {_obj+Object::px}, {_px}
   moveToX_rect {_obj+Object::bounds}, {_px}
.ENDMACRO

.MACRO moveToY_object _obj, _py
   ldm16 {_obj+Object::py}, {_py}
   moveToY_rect {_obj+Object::bounds}, {_py}
.ENDMACRO

.MACRO moveTo_object _obj, _px, _py
   moveToX_object {_obj}, {_px}
   moveToY_object {_obj}, {_py}
.ENDMACRO

;Set Object Velocity:
.MACRO set_vx_object _obj, _vx
   ldm16 {_obj+Object::vx}, {_vx}
.ENDMACRO
.MACRO set_vy_object _obj, _vy
   ldm16 {_obj+Object::vy}, {_vy}
.ENDMACRO
;Set Object Acceleration:
.MACRO set_ax_object _obj, _ax
   ldm16 {_obj+Object::ax}, {_ax}
.ENDMACRO
.MACRO set_ay_object _obj, _ay
   ldm16 {_obj+Object::ay}, {_ay}
.ENDMACRO

;Apply Pysics to Object:
.MACRO apply_physics_object _obj
.SCOPE
   add16 {_obj+Object::vx}, {_obj+Object::ax}
   add16 {_obj+Object::vy}, {_obj+Object::ay}
   ;Check sign of Velocity:
   ldm16 macro_temp, {_obj+Object::vx}
   asr16 macro_temp, #OBJECT_VX_SHIFT
   add16 {_obj+Object::px}, macro_temp
   ldm16 macro_temp, {_obj+Object::vy}
   asr16 macro_temp, #OBJECT_VY_SHIFT
   add16 {_obj+Object::py}, macro_temp
.ENDSCOPE
.ENDMACRO

;Copy Object to OAM:
.MACRO copy_to_oam_object _obj, _slot
.SCOPE
   ;Copy Object data to temp Object:
   copy_object {copy_obj}, {_obj}
   sub16 {copy_obj+Object::px}, {camera+Camera::bounds+Rect::left}
   lda camera+Camera::offset_x
   bmi :+
      add8 {copy_obj+Object::px}, {camera+Camera::offset_x}
      lda copy_obj+Object::px
      adc #0
      sta copy_obj+Object::px
      jmp :++
   :
      sub8 {copy_obj+Object::px}, {camera+Camera::offset_x}
      lda copy_obj+Object::px
      sbc #0
      sta copy_obj+Object::px
   :
   sub16 {copy_obj+Object::py}, {camera+Camera::bounds+Rect::top}
   lda camera+Camera::offset_y
   bmi :+
      add8 {copy_obj+Object::py}, {camera+Camera::offset_y}
      lda copy_obj+Object::py
      adc #0
      sta copy_obj+Object::py
      jmp :++
   :
      sub8 {copy_obj+Object::py}, {camera+Camera::offset_y}
      lda copy_obj+Object::py
      sbc #0
      sta copy_obj+Object::py
   :
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
