;Earthlight
;main functions

lorom

org $2FFFFF
	db $FF ;expand to 12 Mbits

org $FFD7
	db $0B ;change ROM size? original: 0A

org $FFD5
	db $30 ;FastROM On, original $20

;org $FFDC
	;dw $0000 ;should we fix checksum?

;org $FFDE
	;dw $0000

;org $0099B0 ;hook into original kanji render
	;*** lda #$00
	;*** xba
	;*** lda $0757
	;jml RenderMessage ;DB is $08, P is $30

org $0099CC
HookExit: ;original
	ply ;***
	rts ;***


!messageID    = $0757
!indentTile   = $075B
!indentLine   = $075C
!frameCounter = $0805

!pointListH   = $0FFF
!pointListM   = $0FFE
!pointListL   = $0FFD
!currCharH    = $2F ;$0FF2
!currCharM    = $2E ;$0FF1
!currCharL    = $2D ;$0FF0
!bytesWritten = $0FF3
!charsWritten = $0FF4

org $A08000 ;start of expanded space, fastrom mirror
RenderMessage:
	sep #$30
	phk
	plb
bank $A0 ;assume current bank

;translate old pointer list $0a (07A800,07E64A,07C5CF) to new address ($A18000,$A28000,$A38000)

	lda $09 ;pick middle byte for switch
	cmp #$A8
	beq .caseList1
	cmp #$E6
	beq .caseList2
	lda $#A3
	bra .ListDone
.caseList1:
	lda $#A1
	bra .ListDone
.caseList2:
	lda $#A2
.ListDone:
	sta !pointListH
	sta !currCharH
	lda #$80
	sta !pointListM
	lda #$00
	sta !pointListL

	rep #$20
	ldy !messageID
	lda [!pointListL],y
	sta !currCharL
	sep #$20
	ldx #$0000
.nextChar:
	stz !bytesWritten
	lda [!currCharL]
	cmp #$FF
	beq .msgDone
	cmp #$FE
	beq .lineFeed
	cmp #$00
	beq .printSpace
	rep #$20
	asl ;*8 for font entry
	asl
	asl
	tay
	sep #$20
.nextByte: {
	lda Font,y
	sta $7F0006,x
	inx
	stz $7F0006,x
	inx
	iny
	inc !bytesWritten
	lda !bytesWritten
	cmp #$10
	bne .nextByte
	}
	;inc !charsWritten
	inc !currCharL
	bra .nextChar
.lineFeed:
	bra .nextChar
.printSpace:
	rep #20
	ldy #$0000
.nextZero: { ;don't need Y for this, can use it as counter
	stz $7F0006,x
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
	lda !frameCounter
.waitFrame:	
	cmp !frameCounter
	beq .waitFrame

;wait for frame advance
;dma to vram
;point original char pointer to a $0000 for empty message, so it skips rendering 

	sep #$30
	lda #$08
	pha
	plb
	jml HookExit ;restore and return

Font:
incbin "../Graphics/steely8.til"

incsrc "Graphics.asm"

