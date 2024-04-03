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

!pointListL   = $0FFF
!pointListW   = $0FFE
!pointListB   = $0FFD
!currCharL    = $2F ;$0FF2
!currCharW    = $2E ;$0FF1
!currCharB    = $2D ;$0FF0
!charsWritten = $0FF3

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
.caseList2
lda $#A2
.ListDone:
sta !pointListL
sta !currCharL
lda #$80
sta !pointListW
lda #$00
sta !pointListB

rep #$20
ldy !messageID
lda [!pointlistL],y
sta !currCharB


;special cases: end of msg, linefeed (pad from written chars to full line
;pick char from font
;copy to 7f0006
;count written chars
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

