;--------------------------------------------
    ;Controller_Reading routine
    ;_pad=>A|B|Sel|St|U|D|L|R
    ;Bits=>7|6|5  |4 |3|2|1|0
.PROC read_controller
    ;store last state of controller
    lda _pad
    sta _pad_last
    ;reset serial output counter of controller
    lda #$01
    sta $4016
    lda #$00
    sta $4016
    ;also reset _pad variable
    sta _pad
    ldx #08         ;do for 8 buttons
    ;clear carry Bit:
    clc
    read:
        lda $4016
        ror A       ;transfers incomming bit to Carry
        rol _pad    ;shifts in pressed button
        dex
        bne read
rts
.ENDPROC
;--------------------------------------------
