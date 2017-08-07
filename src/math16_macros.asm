;--------------------------------------------
; MATH16 MACROS
; 16-Bit Arithmetic
;--------------------------------------------
.SEGMENT "CODE"

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
.MACRO inc16 _a
.SCOPE
   .IF .MATCH(.LEFT(1,{_a}),#)
      .ERROR "Illegal addressing Mode"
   .ENDIF
    inc _a
    bne no_ovf
        inc _a+1
    no_ovf:
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
.MACRO dec16 _a
.SCOPE
   .IF .MATCH(.LEFT(1,{_a}),#)
      .ERROR "Illegal addressing Mode"
   .ENDIF
    sta macro_temp
    lda _a
    sec
    sbc #$01
    sta _a
    lda _a+1
    sbc #$00
    sta _a+1
    bne no_ovf
        lda _a
    no_ovf:
    php
    lda macro_temp
    plp
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
.MACRO lsl16 _a, _b
   asl16 {_a}, {_b}
.ENDMACRO
;--------------------------------------------
.MACRO lsr16 _a, _b
  .IF .MATCH(.LEFT(1,{_a}),#)
      .ERROR "Invalid Parameter..."
   .ELSEIF .PARAMCOUNT = 1
      lsr _a+1
      ror _a
   .ELSEIF .PARAMCOUNT = 2 && .MATCH(.LEFT(1,{_b}),#)
      .REPEAT .RIGHT(.TCOUNT({_b})-1, _b)
         lsr16 {_a}
      .ENDREPEAT
   .ENDIF
.ENDMACRO
;--------------------------------------------
.MACRO asl16 _a, _b
  .IF .MATCH(.LEFT(1,{_a}),#)
      .ERROR "Invalid Parameter..."
   .ELSEIF .PARAMCOUNT = 1
      asl _a
      rol _a+1
   .ELSEIF .PARAMCOUNT = 2 && .MATCH(.LEFT(1,{_b}),#)
      .REPEAT .RIGHT(.TCOUNT({_b})-1, _b)
         asl16 {_a}
      .ENDREPEAT
   .ENDIF
.ENDMACRO
;--------------------------------------------
.MACRO asr16 _a, _b
  .IF .MATCH(.LEFT(1,{_a}),#)
      .ERROR "Invalid Parameter..."
   .ELSEIF .PARAMCOUNT = 1
      pha
      lda _a+1
      cmp #$80
      ror _a+1
      ror _a
      pla
   .ELSEIF .PARAMCOUNT = 2 && .MATCH(.LEFT(1,{_b}),#)
      pha
      .REPEAT .RIGHT(.TCOUNT({_b})-1, _b)
         lda _a+1
         cmp #$80
         ror _a+1
         ror _a
      .ENDREPEAT
      pla
   .ENDIF
.ENDMACRO
;--------------------------------------------
.MACRO add16 _a, _b
   lda _a
   clc
   .IF .MATCH(.LEFT(1,{_b}),#)
      adc #<.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      adc _b
   .ENDIF
   sta _a
   lda _a+1
   .IF .MATCH(.LEFT(1,{_b}),#)
      adc #>.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      adc _b+1
   .ENDIF
   sta _a+1
.ENDMACRO
;--------------------------------------------
.MACRO sub16 _a, _b
   lda _a
   sec
   .IF .MATCH(.LEFT(1,{_b}),#)
      sbc #<.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      sbc _b
   .ENDIF
   sta _a
   lda _a+1
   .IF .MATCH(.LEFT(1,{_b}),#)
      sbc #>.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      sbc _b+1
   .ENDIF
   sta _a+1
.ENDMACRO
;--------------------------------------------
.MACRO cmp16u _a, _b
.SCOPE
   sta macro_temp
   .IF .MATCH(.LEFT(1,{_a}),#) && .MATCH(.LEFT(1,{_b}),#)
      ;Compare upper Bytes:
      lda #>.RIGHT(.TCOUNT({_a})-1, _a)
      cmp #>.RIGHT(.TCOUNT({_b})-1, _b)
      ;if equal, compare lower Byte:
      bne high_not_equal
        lda #<.RIGHT(.TCOUNT({_a})-1, _a)
        cmp #<.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSEIF .MATCH(.LEFT(1,{_a}),#)
      ;Compare upper Bytes:
      lda #>.RIGHT(.TCOUNT({_a})-1, _a)
      cmp _b+1
      ;if equal, compare lower Byte:
      bne high_not_equal
        lda #<.RIGHT(.TCOUNT({_a})-1, _a)
        cmp _b
   .ELSEIF .MATCH(.LEFT(1,{_b}),#)
      ;Compare upper Bytes:
      lda _a+1
      cmp #>.RIGHT(.TCOUNT({_b})-1, _b)
      ;if equal, compare lower Byte:
      bne high_not_equal
        lda _a
        cmp #<.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      ;Compare upper Bytes:
      lda _a+1
      cmp _b+1
      ;if equal, compare lower Byte:
      bne high_not_equal
        lda _a
        cmp _b
   .ENDIF
   high_not_equal:
   php
   lda macro_temp
   plp
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
.MACRO cmp16s _a, _b
.SCOPE
   sta macro_temp
   sec
   .IF .MATCH(.LEFT(1,{_a}),#) && .MATCH(.LEFT(1,{_b}),#)
      ;Compare upper Bytes:
      lda #>.RIGHT(.TCOUNT({_a})-1, _a)
      sbc #>.RIGHT(.TCOUNT({_b})-1, _b)
      pha
      bvs :+
         eor #$80
      :
      asl
      pla
      ;if equal, compare lower Byte:
      bne high_not_equal
        lda #<.RIGHT(.TCOUNT({_a})-1, _a)
        cmp #<.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSEIF .MATCH(.LEFT(1,{_a}),#)
      ;Compare upper Bytes:
      lda #>.RIGHT(.TCOUNT({_a})-1, _a)
      sbc _b+1
      pha
      bvs :+
         eor #$80
      :
      asl
      pla
      ;if equal, compare lower Byte:
      bne high_not_equal
        lda #<.RIGHT(.TCOUNT({_a})-1, _a)
        cmp _b
   .ELSEIF .MATCH(.LEFT(1,{_b}),#)
      ;Compare upper Bytes:
      lda _a+1
      sbc #>.RIGHT(.TCOUNT({_b})-1, _b)
      pha
      bvs :+
         eor #$80
      :
      asl
      pla
      ;if equal, compare lower Byte:
      bne high_not_equal
        lda _a
        cmp #<.RIGHT(.TCOUNT({_b})-1, _b)
   .ELSE
      ;Compare upper Bytes:
      lda _a+1
      sbc _b+1
      pha
      bvs :+
         eor #$80
      :
      asl
      pla
      ;if equal, compare lower Byte:
      bne high_not_equal
        lda _a
        cmp _b
   .ENDIF
   high_not_equal:
   php
   lda macro_temp
   plp
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
.MACRO mult _a, _b
.SCOPE
    ;Result stored in mult_result:
   .IF .MATCH(.LEFT(1,{_a}),#) && .MATCH(.LEFT(1,{_b}),#)
      lda #.RIGHT(.TCOUNT({_a})-1, _a)
      cmp #.RIGHT(.TCOUNT({_b})-1, _b)
      bcc :+
         ldm8 arith_a, #.RIGHT(.TCOUNT({_a})-1, _a)
         ldm8 arith_b, #.RIGHT(.TCOUNT({_b})-1, _b)
         jmp do
      :
         ldm8 arith_a, #.RIGHT(.TCOUNT({_b})-1, _b)
         ldm8 arith_b, #.RIGHT(.TCOUNT({_a})-1, _a)
   .ELSEIF .MATCH(.LEFT(1,{_a}),#)
      lda #.RIGHT(.TCOUNT({_a})-1, _a)
      cmp _b
      bcc :+
         ldm8 arith_a, #.RIGHT(.TCOUNT({_a})-1, _a)
         ldm8 arith_b, {_b}
         jmp do
      :
         ldm8 arith_a, {_b}
         ldm8 arith_b, #.RIGHT(.TCOUNT({_a})-1, _a)
   .ELSEIF .MATCH(.LEFT(1,{_b}),#)
      lda _a
      cmp #.RIGHT(.TCOUNT({_b})-1, _b)
      bcc :+
         ldm8 arith_a, {_a}
         ldm8 arith_b, #.RIGHT(.TCOUNT({_b})-1, _b)
         jmp do
      :
         ldm8 arith_a, #.RIGHT(.TCOUNT({_b})-1, _b)
         ldm8 arith_b, {_a}
   .ELSE
      lda _a
      cmp _b
      bcc :+
         ldm8 arith_a, {_a}
         ldm8 arith_b, {_b}
         jmp do
      :
         ldm8 arith_a, {_b}
         ldm8 arith_b, {_a}
   .ENDIF
      do:
         lda #$00
         sta arith_a+1
         sta arith_b+1
         sta mult_result+1
         ldx arith_b
         beq end
      loop:
         clc
         adc arith_a
         dex
         bne loop
      end:
         sta mult_result
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
.MACRO div _a, _b
.SCOPE
    ;Result stored in div_result
    ;Modulu stored in mod_result:
    ldx #$00
    stx arith_a+1
    stx arith_b+1
    stx div_result+1
    stx mod_result+1
   .IF .MATCH(.LEFT(1,{_a}),#) && .MATCH(.LEFT(1,{_b}),#)
      ldm8 arith_a, #.RIGHT(.TCOUNT({_a})-1, _a)
      beq end
      ldm8 arith_b, #.RIGHT(.TCOUNT({_b})-1, _b)
      beq end
   .ELSEIF .MATCH(.LEFT(1,{_a}),#)
      ldm8 arith_a, #.RIGHT(.TCOUNT({_a})-1, _a)
      beq end
      ldm8 arith_b, {_b}
      beq end
   .ELSEIF .MATCH(.LEFT(1,{_b}),#)
      ldm8 arith_a, {_a}
      beq end
      ldm8 arith_b, #.RIGHT(.TCOUNT({_b})-1, _b)
      beq end
   .ELSEIF .MATCH(.LEFT(1,{_b}),#)
      ldm8 arith_a, {_a}
      beq end
      ldm8 arith_b, {_b}
      beq end
   .ENDIF
   lda arith_a
    sec
    loop:
        sbc arith_b
        bcc last
        inx
        jmp loop
    last:
        adc arith_b
    end:
    sta mod_result
    stx div_result
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
.MACRO mult16 _a, _b
.SCOPE
    ;Result stored in mult_result:
   .IF .MATCH(.LEFT(1,{_a}),#) && .MATCH(.LEFT(1,{_b}),#)
      cmp16u #.RIGHT(.TCOUNT({_a})-1, _a), #.RIGHT(.TCOUNT({_b})-1, _b)
      bcc :+
         ldm16 arith_a, #.RIGHT(.TCOUNT({_a})-1, _a)
         ldm16 arith_b, #.RIGHT(.TCOUNT({_b})-1, _b)
         jmp do
      :
         ldm16 arith_a, #.RIGHT(.TCOUNT({_b})-1, _b)
         ldm16 arith_b, #.RIGHT(.TCOUNT({_a})-1, _a)
   .ELSEIF .MATCH(.LEFT(1,{_a}),#)
      cmp16u #.RIGHT(.TCOUNT({_a})-1, _a), {_b}
      bcc :+
         ldm16 arith_a, #.RIGHT(.TCOUNT({_a})-1, _a)
         ldm16 arith_b, {_b}
         jmp do
      :
         ldm16 arith_a, {_b}
         ldm16 arith_b, #.RIGHT(.TCOUNT({_a})-1, _a)
   .ELSEIF .MATCH(.LEFT(1,{_b}),#)
      cmp16u {_a}, #.RIGHT(.TCOUNT({_b})-1, _b)
      bcc :+
         ldm16 arith_a, {_a}
         ldm16 arith_b, #.RIGHT(.TCOUNT({_b})-1, _b)
         jmp do
      :
         ldm16 arith_a, #.RIGHT(.TCOUNT({_b})-1, _b)
         ldm16 arith_b, {_a}
   .ELSE
      cmp16u {_a}, {_b}
      bcc :+
         .IF ({_a} = arith_a) || ({_a} = arith_b) || ({_b} = arith_a) || ({_b} = arith_b)
            ldm16 macro_temp, arith_a
            ldm16 arith_a, arith_b
            ldm16 arith_b, macro_temp
            jmp do
         .ELSE
            ldm16 arith_a, {_b}
            ldm16 arith_b, {_a}
         .ENDIF
      :
         .IF ({_a} = arith_a) || ({_a} = arith_b) || ({_b} = arith_a) || ({_b} = arith_b)
         .ELSE
            ldm16 arith_a, {_a}
            ldm16 arith_b, {_b}
         .ENDIF
   .ENDIF
   do:
      cmp16u arith_a, #0
      beq end
         cmp16u arith_b, #0
         beq end
            ldm16 mult_result, #0
            loop:
               lda mult_result
               clc
               adc arith_a
               sta mult_result
               lda mult_result+1
               adc arith_a+1
               sta mult_result+1
               dec16 arith_b
               bne loop
   end:
.ENDSCOPE
.ENDMACRO
;--------------------------------------------
.MACRO div16 _a, _b
.SCOPE
    ;Result stored in div_result
    ;Modulu in mod_result:
    .IF _a = arith_a || _a = arith_b || _b = arith_a || _b = arith_b
    .ELSE
        ldm16 arith_a, _a
        ldm16 arith_b, _b
    .ENDIF
    ldm16 div_result, #$0000
    ldm16 mod_result, #$0000
    cmp16u arith_b, #$0000
    beq end
    cmp16u arith_a, #$0000
    beq end
    sec
    loop:
        sub16 arith_a, arith_b
        bcc last
        inc16 div_result
        jmp loop
    last:
        add16 arith_a, arith_b
    end:
        ldm16 mod_result, arith_a
.ENDSCOPE
.ENDMACRO
;--------------------------------------------


