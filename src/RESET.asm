;--------------------------------------------
;Reset Code for CA65/CC65:
;--------------------------------------------
.segment "STARTUP"
.PROC RESET
    sei     ;ignore IRQs
    cld     ;disable decimal mode
    ;Set Stack to $FF:
    ldx #$FF
    txs
    
    ;Reset Registers:
    inx             ;X = $00
    stx PPU_CTRL    ;disable NMI
    stx PPU_MASK    ;disable rendering
    stx APU_DMC     ;disable DMC IRQs
    stx APU_STATUS  ;disable music channels
    ;Disable APU Frame IRQ:
    lda #$40
    sta APU_FRAME_COUNTER

    ;Wait for VBlank (PPU Warmup):
    vbw
    
    ;Clear RAM:
    txa             ;A = $00
    @clear_ram:
        sta $0000,x
        sta $0100,x
        sta $0200,x
        sta $0300,x
        sta $0400,x
        sta $0500,x
        sta $0600,x
        inx
        bne @clear_ram
    
    ;Clear NameTables (VRAM $2000-$2FFF):
    ldy PPU_STATUS
    txa
    lda #$20
    sta PPU_ADDRESS
    txa
    sta PPU_ADDRESS
    ldy #$10        ;16 x 256 Bytes = 4 KBytes
    @clear_nt:
        sta PPU_DATA
        inx
        bne @clear_nt
            dey
            bne @clear_nt
    
    ;Clear OAM and OAM Buffer:
    lda #$FF
    @clear_oam_buffer:
        sta oam_buffer,x
        inx
        bne @clear_oam_buffer
    oam_dma oam_buffer

    ;Wait once more for VBlank (PPU Warmup):
    vbw

    ;jump to begin of actual code:
    jmp rex_runner_begin
.ENDPROC
