;--------------------------------------------
; .MACRO DEFINES:
;--------------------------------------------
.SEGMENT "CODE"

;Controller:
;_pad=>A|B|Sel|St|U|D|L|R
;Bits=>7|6|5  |4 |3|2|1|0
    .define KEY_A       #$80
    .define KEY_B       #$40
    .define KEY_SELECT  #$20
    .define KEY_START   #$10
    .define KEY_UP      #$08
    .define KEY_DOWN    #$04
    .define KEY_LEFT    #$02
    .define KEY_RIGHT   #$01
    .define KEY_HIGH    #$F0;A.B,Sel,St
    .define KEY_DIR     #$0F;D-Pad
    .define KEY_ANY     #$FF
;States for Buttons:
    PUSH        = 1
    HOLD        = 0
    RELEASE     = -1
    NOT_PRESSED = -2
;Decleration for Boolean Operation on any Byte:
    BIT_0       = 0
    BIT_1       = 1
    BIT_2       = 2
    BIT_3       = 3
    BIT_4       = 4
    BIT_5       = 5
    BIT_6       = 6
    BIT_7       = 7
;Counter for bool Bit address:
    bool_bit_addr = 0
;Define for Register A:
    reg_a       = -1
    reg_x       = -2
    reg_y       = -3
;--------------------------------------------
; MACROS:
;--------------------------------------------
;Missing Logical Shift left:
.MACRO lsl _v
   .IF .PARAMCOUNT = 0
      asl
   .ELSEIF .MATCH(.LEFT(1,{_v}),#)
      .ERROR "Invalid Parameter..."
   .ELSE
      asl _v
   .ENDIF
.ENDMACRO

;Missing Arithmetic Shift right:
.MACRO asr _v
   .IF .PARAMCOUNT = 0
      cmp #$80
      ror
   .ELSEIF .MATCH(.LEFT(1,{_v}),#)
      .ERROR "Invalid Parameter..."
   .ELSE
      pha
      lda _v
      cmp #$80
      ror _v
      pla
   .ENDIF
.ENDMACRO
;--------------------------------------------
;Macro to move Byte:
.MACRO ldm8 _a, _b
   .IF .MATCH(.LEFT(1,{_b}),#)
      lda #.RIGHT(.TCOUNT({_b})-1, {_b})
   .ELSE
      lda _b
   .ENDIF
   sta _a
.ENDMACRO
;--------------------------------------------
;Macro to add Byte:
.MACRO add8 _a, _b
   lda _a
   clc
   .IF .MATCH(.LEFT(1,{_b}),#)
      adc #.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      adc _b
   .ENDIF
   sta _a
.ENDMACRO
;--------------------------------------------
;Macro to subtract Byte:
.MACRO sub8 _a, _b
   lda _a
   sec
   .IF .MATCH(.LEFT(1,{_b}),#)
      sbc #.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      sbc _b
   .ENDIF
   sta _a
.ENDMACRO
;--------------------------------------------
;Unsigned Compare Byte:
.MACRO cmp8u _a, _b
.SCOPE
   sta macro_temp
   .IF .PARAMCOUNT = 1
      .IF .MATCH(.LEFT(1,{_a}),#)
         cmp #.RIGHT(.TCOUNT({_a})-1, _a)
      .ELSE
         cmp _a
      .ENDIF
   .ELSEIF .MATCH(.LEFT(1,{_a}),#) && .MATCH(.LEFT(1,{_b}),#)
      lda #.RIGHT(.TCOUNT({_a})-1, _a)
      cmp #.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSEIF .MATCH(.LEFT(1,{_a}),#)
      lda #.RIGHT(.TCOUNT({_a})-1, _a)
      cmp _b
   .ELSEIF .MATCH(.LEFT(1,{_b}),#)
      lda _a
      cmp #.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      lda _a
      cmp _b
   .ENDIF
   php
   lda macro_temp
   plp
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Signed Compare Byte:
.MACRO cmp8s _a, _b
.SCOPE
   sta macro_temp
   sec
   .IF .PARAMCOUNT = 1
      .IF .MATCH(.LEFT(1,{_a}),#)
         sbc #.RIGHT(.TCOUNT({_a})-1, _a)
      .ELSE
         sbc _a
      .ENDIF
   .ELSEIF .MATCH(.LEFT(1,{_a}),#) && .MATCH(.LEFT(1,{_b}),#)
      lda #.RIGHT(.TCOUNT({_a})-1, _a)
      sbc #.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSEIF .MATCH(.LEFT(1,{_a}),#)
      lda #.RIGHT(.TCOUNT({_a})-1, _a)
      sbc _b
   .ELSEIF .MATCH(.LEFT(1,{_b}),#)
      lda _a
      sbc #.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      lda _a
      sbc _b
   .ENDIF
   pha
   bvs :+
      eor #$80
   :
   asl
   pla
   php
   lda macro_temp
   plp
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Logical Shift left (extended):
.MACRO lsl8 _a, _b
   .IF .PARAMCOUNT = 0
      asl
   .ELSEIF .PARAMCOUNT = 1 && .MATCH(.LEFT(1,{_a}),#)
      .REPEAT .RIGHT(.TCOUNT({_a})-1, _a)
         asl
      .ENDREPEAT
   .ELSEIF .PARAMCOUNT = 2 && .MATCH(.LEFT(1,{_b}),#)
      .REPEAT .RIGHT(.TCOUNT({_b})-1, _b)
         asl _a
      .ENDREPEAT
   .ENDIF
.ENDMACRO
;Logical Shift right (extended):
.MACRO lsr8 _a, _b
   .IF .PARAMCOUNT = 0
      lsr
   .ELSEIF .PARAMCOUNT = 1 && .MATCH(.LEFT(1,{_a}),#)
      .REPEAT .RIGHT(.TCOUNT({_a})-1, _a)
         lsr
      .ENDREPEAT
   .ELSEIF .PARAMCOUNT = 2 && .MATCH(.LEFT(1,{_b}),#)
      .REPEAT .RIGHT(.TCOUNT({_b})-1, _b)
         lsr _a
      .ENDREPEAT
   .ENDIF
.ENDMACRO
;Arithmetic Shift left (extended):
.MACRO asl8 _a, _b
   .IF .PARAMCOUNT = 0
      asl
   .ELSEIF .PARAMCOUNT = 1 && .MATCH(.LEFT(1,{_a}),#)
      .REPEAT .RIGHT(.TCOUNT({_a})-1, _a)
         asl
      .ENDREPEAT
   .ELSEIF .PARAMCOUNT = 2 && .MATCH(.LEFT(1,{_b}),#)
      .REPEAT .RIGHT(.TCOUNT({_b})-1, _b)
         asl _a
      .ENDREPEAT
   .ENDIF
.ENDMACRO
;Arithmetic Shift right (extended):
.MACRO asr8 _a, _b
   .IF .PARAMCOUNT = 0
      asr
   .ELSEIF .PARAMCOUNT = 1 && .MATCH(.LEFT(1,{_a}),#)
      .REPEAT .RIGHT(.TCOUNT({_a})-1, _a)
         asr
      .ENDREPEAT
   .ELSEIF .PARAMCOUNT = 2 && .MATCH(.LEFT(1,{_b}),#)
      .REPEAT .RIGHT(.TCOUNT({_b})-1, _b)
         asr {_a}
      .ENDREPEAT
   .ENDIF
.ENDMACRO
;--------------------------------------------
;Macro used to wait for a Frame
.MACRO wait_frame
.SCOPE
    lda frame_inc
    loop:
    cmp frame_inc
    beq loop;loop until its not equal
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Macro to set PPU_CTRL:
.MACRO set_PPU_CTRL d_val
   .IF .XMATCH(d_val, reg_a)
   .ELSE
      lda d_val
   .ENDIF
   sta PPU_CTRL
   .IF .NOT .XMATCH(d_val, R2000)
      sta R2000
   .ENDIF
   .ENDMACRO
;--------------------------------------------
;Macro to set PPU_MASK:
.MACRO set_PPU_MASK d_val
   .IF .XMATCH (d_val, reg_a)
   .ELSE
      lda d_val
   .ENDIF
   sta PPU_MASK
   .IF .NOT .XMATCH(d_val, R2001)
      sta R2001
   .ENDIF
.ENDMACRO
;--------------------------------------------
;Macro to set PPU_ADDR:
.MACRO set_PPU_ADDR d_val
    lda PPU_STATUS
    .IF .MATCH(.LEFT(1,{d_val}),#)
        lda #>.RIGHT(.TCOUNT({d_val})-1, d_val)
        sta PPU_ADDRESS
        lda #<.RIGHT(.TCOUNT({d_val})-1, d_val)
        sta PPU_ADDRESS
    .ELSE
        lda d_val+1
        sta PPU_ADDRESS
        lda d_val
        sta PPU_ADDRESS
    .ENDIF
.ENDMACRO
;--------------------------------------------
;Macro to set PPU Scroll:
.MACRO set_scroll d_x,d_y
.SCOPE
   lda PPU_STATUS;reset PPU Latch
   lda d_x
   sta PPU_SCROLL
   lda d_y
   sta PPU_SCROLL
   lda d_x+1
   and #1
   beq :+
      lda R2000
      ora #$01
      jmp :++
   :  lda R2000
      and #$FE
   :  sta R2000
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Macro to wait for vblank (read $2002):
.MACRO vbw
.SCOPE
    loop:
        bit PPU_STATUS
        bpl loop
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Macro to write Palette:
.MACRO write_pal d_pal, d_len, d_pal_addr
.SCOPE
   lda PPU_STATUS
   lda #$3F
   sta PPU_ADDRESS
   .IF .MATCH(.LEFT(1,{d_pal_addr}),#)
      lda #<.RIGHT(.TCOUNT({d_pal_addr})-1, d_pal_addr)
   .ELSE
      lda d_pal_addr
   .ENDIF
   sta PPU_ADDRESS
   ldx #$00
   loop:
      lda d_pal,x
      sta PPU_DATA
      inx
      cpx #d_len
      bne loop
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Macro to CHR Data (CHR-RAM):
.MACRO write_chr _chr_start, _chr_end, _vram_addr
.SCOPE
   lda PPU_STATUS
   .IF .MATCH(.LEFT(1,{_chr_start}),#)
      lda #<.RIGHT(.TCOUNT({_chr_start})-1, _chr_start)
      sta pointer
      lda #>.RIGHT(.TCOUNT({_chr_start})-1, _chr_start)
      sta pointer+1
   .ELSE
      lda _vram_addr+1
      sta PPU_ADDRESS
      lda _vram_addr
      sta PPU_ADDRESS
   .ENDIF
   .IF .MATCH(.LEFT(1,{_vram_addr}),#)
      lda #>.RIGHT(.TCOUNT({_vram_addr})-1, _vram_addr)
      sta PPU_ADDRESS
      lda #<.RIGHT(.TCOUNT({_vram_addr})-1, _vram_addr)
      sta PPU_ADDRESS
   .ELSE
      lda _vram_addr+1
      sta PPU_ADDRESS
      lda _vram_addr
      sta PPU_ADDRESS
   .ENDIF
   ldy #$00
   loop:
      lda (pointer),y
      sta PPU_DATA
      iny
      .IF .MATCH(.LEFT(1,{_chr_end}),#)
         cpy #<.RIGHT(.TCOUNT({_chr_end})-1, _chr_end)
      .ELSE
         cpy _chr_end
      .ENDIF
      bne loop
         inc pointer+1
         lda pointer+1
         .IF .MATCH(.LEFT(1,{_chr_end}),#)
            cmp #>.RIGHT(.TCOUNT({_chr_end})-1, _chr_end)
         .ELSE
            cmp _chr_end+1
         .ENDIF
         bne loop
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Clear OAM Slots specified:
.MACRO clear_oam_slot _slot, _size
.SCOPE
   ;Overwrite Y Position with $FF to move objects offscreen:
   ldy _size
   lda _slot
   asl
   asl
   tax
   lda #$FF
   loop:
      sta oam_buffer, x
      inx
      inx
      inx
      inx
      dey
      bne loop
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Macro for OAM DMA:
.MACRO oam_dma d_addr
        lda #<d_addr
        sta $2003
        lda #>d_addr
        sta $4014
.ENDMACRO
;--------------------------------------------
;Macro to create Instructions for vram_instruction_buffer:
.MACRO vram_instruction_set_ppu_addr _addr
   ldm8 {vram_instruction_buffer,x}, #$AD
   inx
   ldm8 {vram_instruction_buffer,x}, #<PPU_STATUS
   inx
   ldm8 {vram_instruction_buffer,x}, #>PPU_STATUS
   inx
   ldm8 {vram_instruction_buffer,x}, #$A9
   inx
   ldm8 {vram_instruction_buffer,x}, #>_addr
   inx
   ldm8 {vram_instruction_buffer,x}, #$8D
   inx
   ldm8 {vram_instruction_buffer,x}, #<PPU_ADDRESS
   inx
   ldm8 {vram_instruction_buffer,x}, #>PPU_ADDRESS
   inx
   ldm8 {vram_instruction_buffer,x}, #$A9
   inx
   ldm8 {vram_instruction_buffer,x}, #<_addr
   inx
   ldm8 {vram_instruction_buffer,x}, #$8D
   inx
   ldm8 {vram_instruction_buffer,x}, #<PPU_ADDRESS
   inx
   ldm8 {vram_instruction_buffer,x}, #>PPU_ADDRESS
   inx
.ENDMACRO

.MACRO vram_instruction_lda_x _src
   ldm8 {vram_instruction_buffer,x}, #$A9
   inx
   ldm8 {vram_instruction_buffer,x}, {_src}
   inx
.ENDMACRO

.MACRO vram_instruction_sta_ppu_data
   ldm8 {vram_instruction_buffer,x}, #$8D
   inx
   ldm8 {vram_instruction_buffer,x}, #<PPU_DATA
   inx
   ldm8 {vram_instruction_buffer,x}, #>PPU_DATA
   inx
.ENDMACRO
;--------------------------------------------
;Prints Text at given offset:
.MACRO print_text d_text_x,d_text_y,d_text_pointer
    ;Calculate PPU start addr for Text:
    d_ppu_start EQU ((d_text_y*$20)+d_text_x+$2000)
    lda #<d_ppu_start
    sta text_ppu_addr
    lda #>d_ppu_start
    sta text_ppu_addr+1
    ;set base addr:
    lda #<d_text_pointer;ADDR LOW
    sta text_load_addr
    lda #>d_text_pointer;ADDR HIGH
    sta text_load_addr+1
    ;used later for text char counter
    lda #d_text_x
    sta text_x
    ;Start Print Routine:
        jsr call_print_text
.ENDMACRO
;--------------------------------------------
;Writes Line of Text to ROM, always appends '\n' to end
.MACRO line d_text
    DB d_text,$0A
.ENDMACRO
;--------------------------------------------
;Macro to check for Buttons Pressed on Controller
.MACRO check_ctrl _btn, _state
.SCOPE
   .IF .XMATCH(_state, HOLD)
      lda _pad_last
      and _btn
      beq not_true
         lda _pad
         and _btn
         beq not_true
   .ELSEIF .XMATCH(_state, PUSH)
      lda _pad_last
      and _btn
      bne not_true
         lda _pad
         and _btn
         beq not_true
   .ELSEIF .XMATCH(_state, RELEASE)
      lda _pad_last
      and _btn
      beq not_true
         lda _pad
         and _btn
         bne not_true
   .ELSEIF .XMATCH(_state, NOT_PRESSED)
      lda _pad_last
      and _btn
      bne not_true
         lda _pad
         and _btn
         bne not_true
   .ELSE
      .ERROR "Invalid Parameter..."
   .ENDIF
         lda #1
         jmp end
      not_true:
         lda #0
   end:
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Macro to check if Variable is equal to given Value:
.MACRO check d_check, d_condition, d_instruction
.SCOPE
    ;load Variable and compare:
    lda d_check
    cmp d_condition
    bne + ;if not equal, skip
        d_instruction
    +:
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Macro to check if a Bit is set TRUE or FALSE:
.MACRO check_bool d_check,d_condition,d_instruction
.SCOPE
    ;load Bit and check it:
    lda bool_addr+#(d_check/8);Calculate bool_index by dividing the given Bit addr by 8:
    and #(1<<(d_check .mod 8));This returns a number between 0 and 7
    .IF d_condition=FALSE
        bne +;if not 0, do nothing (true)
            d_instruction
        +:
    .ELSE;Check for TRUE
        beq +;if 0, do nothing (false)
            d_instruction
        +:
    .ENDIF
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
;Macro to set a Bool Bit:
.MACRO set_bool d_bool_bit,d_val
    ;load Bit and clear it:
    lda bool_addr+(d_bool_bit/8);Calculate bool_index by dividing the given Bit addr by 8:
    and #(~(1<<(d_bool_bit .mod 8))&$FF);This clears selected Bit
    ;Only a check for TRUE is needed, Bit gets always cleared
    .IF d_val=TRUE
        ora #(1<<(d_bool_bit .mod 8));This sets selected Bit
    .ENDIF
    sta bool_addr+(d_bool_bit/8);Store new Byte to appropriate Location
.ENDMACRO
;--------------------------------------------

