;--------------------------------------------
; MAIN :
;--------------------------------------------
.SEGMENT "CODE"

.PROC main
   wait_frame
   jsr RAND
   
   ;Game Logic:
   jsr rex_logic
   update_camera camera
   moveToY_camera camera, #0
   
   ;Set Scroll:
   ldm16 scroll_x, camera+Camera::bounds+Rect::left
   ldm8 scroll_y, camera+Camera::bounds+Rect::top
   
   ;Copy Objects to OAM:
   copy_to_oam_object rex_obj, #0
   copy_to_oam_object dummy_obj, #14
   
   ;Update BG:
   jsr update_bg
   
   jmp main
;--------------------------------------------
;Rex Logic:
rex_logic:
   apply_physics_object rex_obj
   
   cmp16s rex_obj+Object::py, #0
   bcs not_on_top
      moveToY_object rex_obj, #0
   not_on_top:

   cmp16s rex_obj+Object::py, #180
   bcc not_on_ground
      moveToY_object rex_obj, #180
   not_on_ground:
   
   ;Check if button is held down:
   check_ctrl KEY_RIGHT, HOLD
   beq right_not_hold
      set_ax_object rex_obj, #3
   right_not_hold:
   
   check_ctrl KEY_LEFT, HOLD
   beq left_not_hold
      set_ax_object rex_obj, #-3
   left_not_hold:
   
   check_ctrl KEY_RIGHT, NOT_PRESSED
   bne :+
      jmp left_right_pressed
      : check_ctrl KEY_LEFT, NOT_PRESSED
      bne :+
         jmp left_right_pressed
      ;Check which direction Rex is going:
         : cmp16s rex_obj+Object::vx, #0
         ;If 0, no decellaration is applied:
         bne :+
            jmp no_decel
         ;If less 0, then accel positive:
         : bcc accel_positive
            cmp16s rex_obj+Object::vx, #2
            bcc end_accel_positive
               set_ax_object rex_obj, #-2
               jmp left_right_pressed
            end_accel_positive:
               set_ax_object rex_obj, #0
               set_vx_object rex_obj, #0
               jmp left_right_pressed
         accel_positive:
            cmp16s rex_obj+Object::vx, #-2
            bcs end_accel_negative
               set_ax_object rex_obj, #2
               jmp left_right_pressed
            end_accel_negative:
               set_ax_object rex_obj, #0
               set_vx_object rex_obj, #0
               jmp left_right_pressed
      no_decel:
         set_ax_object rex_obj, #0
   left_right_pressed:
   
   check_ctrl KEY_A, PUSH
   beq a_not_pushed
   ;Jump up:
      set_vy_object rex_obj, #-50
   a_not_pushed:
   ;Apply Gravity:
   set_ay_object rex_obj, #3
   
   
   
   ;Check accel direction:
   check_vx:
      lda rex_obj+Object::ax+1
      bmi accel_backwards
      ;Accel forwards:
         cmp16s rex_obj+Object::vx, #OBJECT_MAX_VX
         bcc forward_max_not_reached
            set_vx_object rex_obj, #OBJECT_MAX_VX
         forward_max_not_reached:
            jmp check_vy
      accel_backwards:
         cmp16s rex_obj+Object::vx, #-OBJECT_MAX_VX
         bcs backward_min_not_reached
            set_vx_object rex_obj, #-OBJECT_MAX_VX
         backward_min_not_reached:
   check_vy:
      lda rex_obj+Object::ay+1
      bmi accel_up
      ;Accel down:
         cmp16s rex_obj+Object::vy, #OBJECT_MAX_VY
         bcc down_max_not_reached
            set_vy_object rex_obj, #OBJECT_MAX_VY
         down_max_not_reached:
            jmp end_check_vel
      accel_up:
         cmp16s rex_obj+Object::vy, #-OBJECT_MAX_VY
         bcs up_min_not_reached
            set_vy_object rex_obj, #-OBJECT_MAX_VY
         up_min_not_reached:
   end_check_vel:
rts
.ENDPROC
;--------------------------------------------
.PROC update_bg
;Write to vram_instruction_buffer, last write is RTS ($60):
   ldx #0
   ldy #0
loop:
;   ldm8 {vram_instruction_buffer,x}, #$60
;   inx
;   bne loop
;   vram_instruction_set_ppu_addr $3F11
;   vram_instruction_lda_x $100
;   vram_instruction_sta_ppu_data
;   vram_instruction_lda_x $100
;   vram_instruction_sta_ppu_data
;   inc $100
;   cmp8u $100, #$3C
;   bne :+
;      ldm8 $100, #$31
;   :
end:
   ldm8 {vram_instruction_buffer,x}, #$60
   rts
.ENDPROC
