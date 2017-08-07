;Add Pointers to Frames of the Animation:
rex_animation:
   .WORD rex_frame_0, rex_frame_1
;Specify the total Size (amount of Frames) for the Animation:
rex_animation_size:
   .BYTE 2
   
;Container for Inforamtion of one Frame of the Animation: 1. line is a pointer list
;containing pointer to the different required information of the Frame
;(Tiles, X/Y Position of Tile, Attr, Total Amount of Sprite slots used for Frame)
;Order of Pointers must be kept, Size occurs first!
rex_frame_0:      .WORD rex_frame_0_tiles, rex_frame_0_tiles_x, rex_frame_0_tiles_y, rex_frame_0_attr
   ;Amount of Sprite slots used by Frame:
   rex_frame_0_size: .BYTE 14
   ;Tile Numbes assigned to Sprite Slot:
   rex_frame_0_tiles:
      .BYTE $04, $05, $12, $13, $14, $15, $20, $21, $22, $23, $24, $31, $32, $33
   ;Tile X Position for Sprite:
   rex_frame_0_tiles_x:
      .BYTE 32, 40, 16, 24, 32, 40, 0, 8, 16, 24, 32, 8, 16, 24
   ;Tile Y Position for Sprite:
   rex_frame_0_tiles_y:
      .BYTE 0, 0, 8, 8, 8, 8, 16, 16, 16, 16, 16, 24, 24, 24
   ;Tile Attribute for Sprite:
   rex_frame_0_attr:
      .BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
   
rex_frame_1:      .WORD rex_frame_1_tiles, rex_frame_1_tiles_x, rex_frame_1_tiles_y, rex_frame_1_attr
rex_frame_1_size: .BYTE 7
   rex_frame_1_tiles:
      .BYTE $40, $41, $42, $43, $44, $45, $46
   rex_frame_1_tiles_x:
      .BYTE 0, 8, 16, 24, 32, 40, 48
   rex_frame_1_tiles_y:
      .BYTE 0, 0, 0, 0, 0, 0, 0
   rex_frame_1_attr:
      .BYTE 0, 0, 0, 0, 0, 0, 0
   