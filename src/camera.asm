;--------------------------------------------
; CAMERA MACROS
;--------------------------------------------
.SEGMENT "CODE"
;Struct for Objects:
.struct Camera
   bounds   .tag Rect
   offset_x .byte
   offset_y .byte
   object_p .word
   follow_flag .byte
.endstruct

;Set Camera position:
.MACRO set_camera _cam, _x, _y, _w, _h
   ldm16 {_cam+Camera::bounds+Rect::left},   {_x}
   ldm16 {_cam+Camera::bounds+Rect::right},  {_x}
   ldm16 {_cam+Camera::bounds+Rect::top},    {_y}
   ldm16 {_cam+Camera::bounds+Rect::bottom}, {_y}
   add16 {_cam+Camera::bounds+Rect::right},  {_w}
   add16 {_cam+Camera::bounds+Rect::bottom}, {_h}
.ENDMACRO

;Set Object to follow with camera:
.MACRO set_follow_object_camera _cam, _obj
   ldm16 {_cam+Camera::object_p}, {_obj}
   follow_enable_camera {_cam}
.ENDMACRO
.MACRO follow_enable_camera _cam
   ldm8 {_cam+Camera::follow_flag}, #1
.ENDMACRO
.MACRO follow_disable_camera _cam
   ldm8 {_cam+Camera::follow_flag}, #0
.ENDMACRO

;Set Offset of Camera to Object:
.MACRO offset_x_camera _cam, _offx
   ldm8 {_cam+Camera::offset_x}, {_offx}
.ENDMACRO
.MACRO offset_y_camera _cam, _offy
   ldm8 {_cam+Camera::offset_y}, {_offy}
.ENDMACRO
.MACRO offset_camera _cam, _offx, _offy
   offset_x_camera {_cam}, {_offx}
   offset_y_camera {_cam}, {_offy}
.ENDMACRO

;Set Camera Position:
.MACRO moveX_camera _cam, _dx
   moveX_rect {_cam+Camera::bounds}, {_dx}
.ENDMACRO
.MACRO moveY_camera _cam, _dy
   moveY_rect {_cam+Camera::bounds}, {_dy}
.ENDMACRO
.MACRO move_camera _cam, _dx, _dy
   moveX_camera {_cam}, {_dx}
   moveY_camera {_cam}, {_dy}
.ENDMACRO

.MACRO moveToX_camera _cam, _px
   moveToX_rect {_cam+Camera::bounds}, {_px}
.ENDMACRO
.MACRO moveToY_camera _cam, _py
   moveToY_rect {_cam+Camera::bounds}, {_py}
.ENDMACRO
.MACRO moveTo_camera _cam, _dx, _dy
   moveToX_camera {_cam}, {_dx}
   moveToY_camera {_cam}, {_dy}
.ENDMACRO

;Update Camera Position:
.MACRO update_camera _cam
.SCOPE
   lda _cam+Camera::follow_flag
   bne :+
      jmp end
   :  ldm16 object_p, {_cam+Camera::object_p}
      ldy #Object::px
      moveToX_camera {_cam}, {(object_p),y}
      ldy #Object::py
      moveToY_camera {_cam}, {(object_p),y}
   end:
.ENDSCOPE
.ENDMACRO

