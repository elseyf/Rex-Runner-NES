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
.MACRO ldm16 _a, _b, _offset
   .IF .MATCH(.LEFT(1,{_b}),#)
      lda #<.RIGHT(.TCOUNT({_b})-1, _b)
      sta _a
      lda #>.RIGHT(.TCOUNT({_b})-1, _b)
      sta _a+1
   .ELSEIF .MATCH(.RIGHT(1,{_b}),y)
      lda _b
      sta _a
      iny
      lda _b
      sta _a+1
      dey
   .ELSE
      lda _b
      sta _a
      lda _b+1
      sta _a+1
   .ENDIF
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
;Macro for OAM DMA:
.MACRO oam_dma d_addr
        lda #<d_addr
        sta $2003
        lda #>d_addr
        sta $4014
.ENDMACRO
;--------------------------------------------
