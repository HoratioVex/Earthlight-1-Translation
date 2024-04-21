;insert translated graphics
lorom

!DataType   = $00AEF5
!DataLength = $00AEF8
!DataSource = $00AEFC

;adjust tilemaps
;clear longer name on main map
org $01DD10 ;does this mess up the RLE?!
	incbin "../Graphics/TM-ClearName1.bin"
org $1DE06 ;squad counter title
	db $13,$00,$11,$00,$00,$00
;longer unit names in combat screen
org $04DBF4
	lda.b #$01


; Weapon Class names for unit description
;04f0d8: -> RAPID : 12000100100009000400
org $04F0D8
	db $12,$00,$01,$00,$10,$00,$09,$00,$04,$00
;04f0c0: -> MELEE : 0d0005000c0005000500
org $04F0C0
	db $0d,$00,$05,$00,$0c,$00,$05,$00,$05,$00
;04f0cc: -> PIERC : 2b002c002d002e002f00
org $04F0CC
	db $2b,$00,$2c,$00,$2d,$00,$2e,$00,$2f,$00
;04f0b4: -> BOMB  : 02000f000d0002000000
org $04F0B4
	db $02,$00,$0f,$00,$0d,$00,$02,$00,$00,$00
	
; Weapon Class names for dock screen
;-> RAPID : 12000100100009000400
org $02A8CA 
	db $12,$00,$01,$00,$10,$00,$09,$00,$04,$00
;-> MELEE : 0d0005000c0005000500
org $02A8E2
	db $0d,$00,$05,$00,$0c,$00,$05,$00,$05,$00
;-> PIERC : 2b002c002d002e002f00
org $02A8D6
	db $2b,$00,$2c,$00,$2d,$00,$2e,$00,$2f,$00
;-> BOMB  : 02000f000d0002000000
org $02A8EE
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

org $75*10+!DataType
	db $61&$f0
org $75*10+!DataLength
	dw TM_75_End-TM_75_Start
org $75*10+!DataSource
	dl TM_75_Start
	
org $6A*10+!DataType
	db $11&$f0
org $6A*10+!DataLength
	dw GR_6A_End-GR_6A_Start
org $6A*10+!DataSource
	dl GR_6A_Start

org $6B*10+!DataType
	db $11&$f0
org $6B*10+!DataLength
	dw GR_6B_End-GR_6B_Start
org $6B*10+!DataSource
	dl GR_6B_Start

org $6C*10+!DataType
	db $11&$f0
org $6C*10+!DataLength
	dw GR_6C_End-GR_6C_Start
org $6C*10+!DataSource
	dl GR_6C_Start

org $6D*10+!DataType
	db $11&$f0
org $6D*10+!DataLength
	dw GR_6D_End-GR_6D_Start
org $6D*10+!DataSource
	dl GR_6D_Start

org $70*10+!DataType
	db $11&$f0
org $70*10+!DataLength
	dw GR_70_End-GR_70_Start
org $70*10+!DataSource
	dl GR_70_Start

org $71*10+!DataType
	db $11&$f0
org $71*10+!DataLength
	dw GR_71_End-GR_71_Start
org $71*10+!DataSource
	dl GR_71_Start


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

TM_75_Start:
	incbin "../Graphics/TM-75-DockView.bin"
TM_75_End:

GR_6A_Start:
	incbin "../Graphics/GR-6A-Commands1.til"
GR_6A_End:

GR_6B_Start:
	incbin "../Graphics/GR-6B-Commands2.til"
GR_6B_End:

GR_6C_Start:
	incbin "../Graphics/GR-6C-Commands3.til"
GR_6C_End:

GR_6D_Start:
	incbin "../Graphics/GR-6D-Commands4.til"
GR_6D_End:

GR_70_Start:
	incbin "../Graphics/GR-70-Combat1.til" 
GR_70_End:

GR_71_Start:
	incbin "../Graphics/GR-71-Combat2.til" 
GR_71_End:



;for each: change location & change compression mode to uncompressed
