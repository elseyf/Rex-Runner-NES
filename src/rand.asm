; Linear congruential pseudo-random number generator
; taken from 6502.org
;
; Calculate SEED = 1664525 * SEED + 1
;
; Enter with:
;
;   SEED0 = byte 0 of seed
;   SEED1 = byte 1 of seed
;   SEED2 = byte 2 of seed
;   SEED3 = byte 3 of seed
;
; Returns:
;
;   SEED0 = byte 0 of seed
;   SEED1 = byte 1 of seed
;   SEED2 = byte 2 of seed
;   SEED3 = byte 3 of seed
;
; TMP is overwritten
;
; For maximum speed, locate each table on a page boundary
;
; Assuming that (a) SEED0 to SEED3 and TMP are located on page zero, and (b)
; all four tables start on a page boundary:
;
;   Space: 58 bytes for the routine
;          1024 bytes for the tables
;   Speed: JSR RAND takes 94 cycles
;
RAND:    CLC       ; compute lower 32 bits of:
         LDX SEED0 ; 1664525 * ($100 * SEED1 + SEED0) + 1
         LDY SEED1
         LDA T0,X
         ADC #1
         STA SEED0
         LDA T1,X
         ADC T0,Y
         STA SEED1
         LDA T2,X
         ADC T1,Y
         STA TMP
         LDA T3,X
         ADC T2,Y
         TAY       ; keep byte 3 in Y for now (for speed)
         CLC       ; add lower 32 bits of:
         LDX SEED2 ; 1664525 * ($10000 * SEED2)
         LDA TMP
         ADC T0,X
         STA SEED2
         TYA
         ADC T1,X
         CLC
         LDX SEED3 ; add lower 32 bits of:
         ADC T0,X  ; 1664525 * ($1000000 * SEED3)
         STA SEED3
         RTS
;Generate Tables for RNG:
T0:
   .REPEAT 256,i
      .BYTE (1664525*i)&$FF
   .ENDREPEAT
T1:
   .REPEAT 256,i
      .BYTE ((1664525*i)>>8)&$FF
   .ENDREPEAT
T2:
   .REPEAT 256,i
      .BYTE ((1664525*i)>>16)&$FF
   .ENDREPEAT
T3:
   .REPEAT 256,i
      .BYTE ((1664525*i)>>24)&$FF
   .ENDREPEAT

