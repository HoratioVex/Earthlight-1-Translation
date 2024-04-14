;insert translated graphics
lorom

;adjust tilemap: clear longer name on main map
org $01DD10
	incbin "../Graphics/TM-ClearName1.bin"

org $A48000

;for each: change location & change compression mode to uncompressed
