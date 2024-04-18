;insert translated graphics
lorom

!DataType   = $00AEF5
!DataLength = $00AEF8
!DataSource = $00AEFC

;adjust tilemap: clear longer name on main map
org $01DD10 ;this messes up the RLE, but somehow it still works?!
	incbin "../Graphics/TM-ClearName1.bin"

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

org $A48000
TM_7D_Start:
	incbin "../Graphics/TM-7D-UnitInfo.bin"
TM_7D_End:

GR_69_Start:
	incbin "../Graphics/GR-69-TileFonts.til"
GR_69_End:


;for each: change location & change compression mode to uncompressed
