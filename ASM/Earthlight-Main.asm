;Earthlight
;main functions

lorom

;System registers 
!MEMSEL       = $420D
!VMAIN        = $2115
!VMADDL       = $2116
!VMADDH       = $2117
!VMDATAL      = $2118
!VMDATAH      = $2119
!DMAP4        = $4340 ;Control
!BBAD4 	      = $4341 ;Destination
!A1T4L        = $4342 ;Source
!A1T4H        = $4343
!A1B4         = $4344
!DAS4L        = $4345 ;Size
!DAS4H        = $4346
!MDMAEN		  = $420B

;used by game
!frameCounter = $0805
!messageID    = $0757
!offsetChar   = $075B
!offsetLine   = $075C
!messageNum   = $07F9
!lineLength   = $079B ;per msg
!targetL      = $075D ;per msg
!targetH      = $077C ;per msg


;used by us
; $FF6-$FFB: free
!currCharH     = $2F
!currCharM     = $2E
!currCharL     = $2D
!bytesLeft     = $0FF6
!tempL         = $0FF7
!tempH         = $0FF8
!RAMBuffer     = $7F0806 ;for graphics decomp, should be free
!PTUnitNames   = $01F8F6 ;pointer table eng unit names
;-----
;Header
org $2FFFFF
	db $00 ;expand to 12 Mbits

org $FFD7
	db $0B ;change ROM size? original: 0A

org $FFD5
	db $30 ;FastROM On, original $20

;org $FFDC
	;dw $0000 ;should we fix checksum?

;org $FFDE
	;dw $0000 ;checksum 2

;-----
;Fixed Length for briefing title
org $05ECC9
	;*** jsl $00984c ;skip first render
	;*** lda $075b ;skip measured length
	lda #$08 ;fixed length, but it's supposed to be padded with quotation marks
	nop #5
;-----
;Fixed Length for map title, load screen
org $08B3FB
	;*** jsl $00984c
	;*** lda $075b
	lda #$0A ;fixed length 
	nop #5
;-----
;Hook pointers for English unit names, main map
org $01D5AD
	jsl LoadPtrUnitNames
	nop #3
;-----
;Hook pointers for English unit names, unit list
org $04E07B
	jsl LoadPtrUnitNames
	nop #3
;-----
org $0099B0 ;hook into original kanji render
	jml RenderMessage ;P is $30
	;*** lda #$00
	;*** xba
	;*** lda $0757
	
org $0099C4
HookExit: ;original code
	lda [$2D] ;***
	sta $29   ;***


org $A08000 ;start of expanded space, fastrom mirror
RenderMessage:
	sep #$20
	phx
	phy
	phb
	
	phk
	plb
	 bank $A0 ;assume current bank
	lda #$01
	sta !MEMSEL ;fastrom on

;translate old pointer list $0a (07A800,07E64A,07C5CF) to new address ($A18000,$A28000,$A38000)

	lda $09 ;pick middle byte for switch
	cmp #$A8
	beq .caseList1
	cmp #$E6
	beq .caseList2
	lda #$A3
	bra .ListDone
.caseList1:
	lda #$A1
	bra .ListDone
.caseList2:
	lda #$A2
.ListDone:
	sta !currCharH ;repurpose to load pointer
	lda #$80
	sta !currCharM
	lda #$00
	sta !currCharL

;first char
	rep #$30
	lda !messageID
	asl ;pointer length=2 bytes
	tay
	lda [!currCharL],y
	sta !currCharL
	ldx #$0000
.nextChar:
	sep #$20
	lda #$08
	sta !bytesLeft
	lda [!currCharL]
	cmp #$00
	beq .printSpace
	cmp #$FE
	beq .lineFeed
	cmp #$FF
	beq .msgDone
	rep #$20
	and #$00FF
	asl #3 ;*8 for font entry
	tay
	sep #$20
	.nextByte: {
		lda #$00
		sta !RAMBuffer,x
		inx
		lda Font,y
		sta !RAMBuffer,x
		inx
		iny
		dec !bytesLeft
		bne .nextByte
		}
.lineFeed: ;ignore, messages are padded
	rep #$20
	inc !currCharL
	bra .nextChar
.printSpace:
	rep #$20
	lda #$0000
	ldy #$0008
	.nextZero: { ;don't need Y for this, can use it as counter
		sta !RAMBuffer,x
		inx
		inx
		dey
		bne .nextZero
		}
	inc !currCharL
	bra .nextChar
.msgDone:
	sep #$20
	stx !tempL ;ram pointer = bytes written
	
;setup DMA	
	sep #$30
	lda #$01
	sta !DMAP4
	lda #$18 ;target vramwrite
	sta !BBAD4
	lda.b #!RAMBuffer     ;l
	sta !A1T4L 
	lda.b #!RAMBuffer>>8  ;m
	sta !A1T4H  
	lda.b #!RAMBuffer>>16 ;h
	sta !A1B4
	lda !tempL
	sta !DAS4L 
	lda !tempH
	sta !DAS4H
;setup VRAM target	
	ldx !messageNum ;store target
	lda !targetL,x
	sta !tempL
	lda !targetH,x
	sta !tempH
	lda !offsetChar ;add offset
	dec
	bpl .addCharOffset
	bra .skipCharOffset
.addCharOffset:
	rep #$20
	and #$00FF
	asl #4 ; *16 for tile, /2 (vram word address)
	clc
	adc !tempL
	sta !tempL
	sep #$20 
	;TODO: add offset line
.skipCharOffset:

;wait for vblank
	lda !frameCounter
.waitFrame:	
	cmp !frameCounter
	beq .waitFrame

;start dma to vram
	lda !tempL
	sta !VMADDL
	lda !tempH
	sta !VMADDH
	lda #$10 ;dma channel 4
	sta !MDMAEN	
		
.Final:  ;finalize and return	
	lda #$07	;point original char pointer to a $0000 (e.g.$07AA47)for empty message, so it skips rendering
	sta !currCharH
	lda #$AA
	sta !currCharM
	lda #$47
	sta !currCharL
	;lda #$00
	;sta !MEMSEL ;fastrom off? who knows
	plb
	ply
	plx
	jml HookExit

Font:
incbin "../Graphics/steely8.til"
;---------------------------------
LoadPtrUnitNames:
	; *** asl asl asl clc adc#$ee66
	asl
	phx
	tax
	lda.l !PTUnitNames,x 
	plx
	rtl

;----------------------------------
incsrc "./Earthlight-Graphics.asm"

