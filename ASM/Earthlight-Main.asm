;Earthlight
;main functions

lorom

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

org $0099B0 ;hook into original kanji render
	jml RenderMessage ;DB is $08, P is $30
	;*** lda #$00
	;*** xba
	;*** lda $0757
	
org $0099C4
HookExit: ;original code
	lda [$2D] ;***
	sta $29   ;***
	
;org $009933
	;lda.b #$01 ;***
	;lda.b #$00 ;check for activate Background

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
!messageID    = $0757
!indentL      = $075B
!indentH      = $075C
!messageNum   = $07F9
!targetL      = $075D
!targetH      = $077C
!frameCounter = $0805

;used by us
; $FF6-$FFB: free
!currCharH     = $2F
!currCharM     = $2E
!currCharL     = $2D
!bytesWritten  = $0FF6
!totalWrittenL = $0FF7
!totalWrittenH = $0FF8
!RAMBuffer     = $7F0006 ;for graphics decomp, should be free

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
	stz !bytesWritten
	lda [!currCharL]
	cmp #$00
	beq .printSpace
	cmp #$FE
	beq .lineFeed
	cmp #$FF
	beq .msgDone
	rep #$20
	and #$00FF
	asl ;*8 for font entry
	asl
	asl
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
	inc !bytesWritten
	lda !bytesWritten
	cmp #$08
	bne .nextByte
	}
.lineFeed: ;ignore, messages are padded
	rep #$20
	inc !currCharL
	bra .nextChar
.printSpace:
	rep #$20
	lda #$0000
	ldy #$0000
.nextZero: { ;don't need Y for this, can use it as counter
	sta !RAMBuffer,x
	inx
	inx
	iny
	cpy #$0008
	bne .nextZero
	}
	inc !currCharL
	bra .nextChar
.msgDone:
	sep #$20
	stx !totalWrittenL
	
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
	lda !totalWrittenL
	sta !DAS4L 
	lda !totalWrittenH
	sta !DAS4H 	

;wait for vblank
	lda !frameCounter
.waitFrame:	
	cmp !frameCounter
	beq .waitFrame

;dma to vram
	ldx !messageNum
	lda !targetL,x
	sta !VMADDL
	lda !targetH,x
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
	lda #$00
	sta !MEMSEL ;fastrom off, who knows
	plb
	ply
	plx
	jml HookExit

Font:
incbin "../Graphics/steely8.til"

incsrc "./Earthlight-Graphics.asm"

