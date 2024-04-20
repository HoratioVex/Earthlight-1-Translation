;insert translated graphics
lorom

!DataType   = $00AEF5
!DataLength = $00AEF8
!DataSource = $00AEFC

;adjust tilemap: clear longer name on main map
org $01DD10 ;does this mess up the RLE?!
	incbin "../Graphics/TM-ClearName1.bin"
org $1de06 ;squad counter title
	db $13,$00,$11,$00,$00,$00
; Weapon Class names for unit description
;04f0d8: -> RAPID : 12000100100009000400
org $04f0d8
	db $12,$00,$01,$00,$10,$00,$09,$00,$04,$00
;04f0c0: -> MELEE : 0d0005000c0005000500
org $04f0c0
	db $0d,$00,$05,$00,$0c,$00,$05,$00,$05,$00
;04f0cc: -> PIERC : 2b002c002d002e002f00
org $04f0cc
	db $2b,$00,$2c,$00,$2d,$00,$2e,$00,$2f,$00
;04f0b4: -> BOMB  : 02000f000d0002000000
org $04f0b4
	db $02,$00,$0f,$00,$0d,$00,$02,$00,$00,$00
;************************************************************************************
org $7D*10+!DataType
	db $60 ;$61 & $f0
org $7D*10+!DataLength
	dw TM_7D_End-TM_7D_Start
org $7D*10+!DataSource
	dl TM_7D_Start
	
org $69*10+!DataType
	db $11&$f0
org $69*10+!DataLength
	dw GR_69_End-GR_69_Start
org $69*10+!DataSource
	dl GR_69_Start

org $6F*10+!DataType
	db $61&$f0
org $6F*10+!DataLength
	dw TM_6F_End-TM_6F_Start
org $6F*10+!DataSource
	dl TM_6F_Start

;***********************************************************************************
org $A48000
TM_7D_Start:
	incbin "../Graphics/TM-7D-UnitInfo.bin"
TM_7D_End:

GR_69_Start:
	incbin "../Graphics/GR-69-TileFonts.til"
GR_69_End:

TM_6F_Start:
	incbin "../Graphics/TM-6F-MainUI.bin"
TM_6F_End:

;for each: change location & change compression mode to uncompressed
