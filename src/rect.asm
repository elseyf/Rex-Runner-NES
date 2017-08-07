;--------------------------------------------
; RECT MACROS
;--------------------------------------------
.SEGMENT "CODE"
;Struct for Rectangle:
.struct Rect
   left     .word
   top      .word
   right    .word
   bottom   .word
.endstruct

;Set Rect:
.MACRO set_rect _rect, _left, _top, _right, _bottom
   ldm16 {_rect+Rect::left},   {_left}
   ldm16 {_rect+Rect::top},    {_top}
   ldm16 {_rect+Rect::right},  {_right}
   ldm16 {_rect+Rect::bottom}, {_bottom}
.ENDMACRO

;Copy Rect:
.MACRO copy_rect _rect1, _rect0
   set_rect {_rect1}, {_rect0+Rect::left}, {_rect0+Rect::top}, {_rect0+Rect::right}, {_rect0+Rect::bottom}
.ENDMACRO

;Move Rect:
.MACRO moveX_rect _rect, _dx
   add16 {_rect+Rect::left},   {_dx}
   add16 {_rect+Rect::right},  {_dx}
.ENDMACRO

.MACRO moveY_rect _rect, _dy
   add16 {_rect+Rect::top},    {_dy}
   add16 {_rect+Rect::bottom}, {_dy}
.ENDMACRO

.MACRO move_rect _rect, _dx, _dy
   moveX_rect {_rect}, {_dx}
   moveY_rect {_rect}, {_dy}
.ENDMACRO

;Move Rect to specific Location:
.MACRO moveToX_rect _rect, _px
   getWidth_rect {_rect}, macro_temp
   ldm16 {_rect+Rect::left},   {_px}
   ldm16 {_rect+Rect::right},  {_px}
   add16 {_rect+Rect::right},  macro_temp
.ENDMACRO

.MACRO moveToY_rect _rect, _py
   getHeight_rect {_rect}, macro_temp
   ldm16 {_rect+Rect::top},    {_py}
   ldm16 {_rect+Rect::bottom}, {_py}
   add16 {_rect+Rect::bottom}, macro_temp
.ENDMACRO

.MACRO moveTo_rect _rect, _px, _py
   moveToX_rect {_rect}, {_px}
   moveToY_rect {_rect}, {_py}
.ENDMACRO

;Get Width:
.MACRO getWidth_rect _rect, _dest
   ldm16 {_dest}, {_rect+Rect::right}
   sub16 {_dest}, {_rect+Rect::left}
.ENDMACRO

;Get Height:
.MACRO getHeight_rect _rect, _dest
   ldm16 {_dest}, {_rect+Rect::bottom}
   sub16 {_dest}, {_rect+Rect::top}
.ENDMACRO

;Check if Point is inside Rect:
.MACRO contains_rect _rect, _px, _py
.SCOPE
   cmp16u {_px}, {_rect+Rect::left}
   bcc not_contained
      cmp16u {_px}, {_rect+Rect::right}
      bcs not_contained
         cmp16u {_py}, {_rect+Rect::top}
         bcc not_contained
            cmp16u {_py}, {_rect+Rect::bottom}
            bcs not_contained
               lda #1
               jmp end
   not_contained:
      lda #0
   end:
.ENDSCOPE
.ENDMACRO

;Check if Rect overlaps another, return bool in A:
.MACRO intersects_rect _rect0, _rect1
.SCOPE
   cmp16u {_rect0+Rect::left}, {_rect1+Rect::right}
   bcs not_intersect
      cmp16u {_rect0+Rect::right}, {_rect1+Rect::left}
      bcc not_intersect
         cmp16u {_rect0+Rect::top}, {_rect1+Rect::bottom}
         bcs not_intersect
            cmp16u {_rect0+Rect::bottom}, {_rect1+Rect::top}
            bcc not_intersect
               lda #1
               jmp end
   not_intersect:
      lda #0
   end:
.ENDSCOPE
.ENDMACRO

