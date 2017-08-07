;--------------------------------------------
; MAIN :
;--------------------------------------------
.SEGMENT "CODE"

.PROC main
      wait_frame
   
   ;Animate Object:
      jsr animate_test_object
      
   ;Copy Object into OAM Slot 0:
      copy_to_oam_object test_obj, #0
      
   jmp main
.ENDPROC
;--------------------------------------------
.PROC animate_test_object
   ;Get Rex Animation Frame Pointers:
   ldm16 pointer, #rex_animation
   ;Get address of current frame:
   lda test_obj_frame_counter
   asl
   tay
   ldm16 $100, {(pointer),y}
   ldm16 pointer, $100
   ;Set new Object Pointers and Size:
   ldy #0
   ldm16 {test_obj+Object::tiles_p}, {(pointer),y}
   iny
   iny
   ldm16 {test_obj+Object::tiles_x_p}, {(pointer),y}
   iny
   iny
   ldm16 {test_obj+Object::tiles_y_p}, {(pointer),y}
   iny
   iny
   ldm16 {test_obj+Object::attr_p}, {(pointer),y}
   iny
   iny
   ldm8  {test_obj+Object::size}, {(pointer),y}
      
   ;Increment Counter and check against size:
   inc test_obj_frame_counter
   lda test_obj_frame_counter
   cmp rex_animation_size
   bcc end
      lda #0
      sta test_obj_frame_counter
end:
   rts
.ENDPROC
   
   