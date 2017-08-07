;--------------------------------------------
; iNES HEADER:
;--------------------------------------------
.SEGMENT "HEADER"
   mirror = $01 ;$00: horizontal, $01: vertical, $08: four-screen
   .byte "NES", $1A, 1, 0, $02 | mirror
   .res 9, $00
