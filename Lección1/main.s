
;---------------- HEADER ---------------------------------------------------

    PRG_COUNT	= 1 	;1 	= 16KB, 2 = 32KB, 3 = 48KB.... (16KB)
	CHR_COUNT	= 1 	;1 	= 8KB, 2 = 16KB, 4 = 32KB....  (8KB)
    INES_REGION	= 1		;0 	= NTSC    1 = PAL

	.db 'N', 'E', 'S', $1A 			;ID 
	.db PRG_COUNT 					;número de bloques PRG-ROM de 16KB
	.db CHR_COUNT 					;número de bloques CHR-ROM de 8KB
	
	.db $0,0,0
		
	.db	INES_REGION & $1			;Región
	; 76543210
	; ||||||||
	; |||||||+- TV system (0: NTSC; 1: PAL)
	; +++++++-- Reservado, poner a cero


	.db $0, $0, $0, $0, $0, $0 		;padding



;-----------------------------------------------------------------
;--------------------------- PRG ROM -----------------------------
;-----------------------------------------------------------------

;------------------ 16KB bank $8000-$BFFF --------------------------
	.base	$8000
	
reset:

 	
;--------------- MAINLOOP ----------------------------

MainLoop:

	jmp MainLoop					;salta a MainLoop



;--------------- VBI int -----------------------------
nmi:	

	rti								;fin de la interrupción


;--------------- IRQ int -----------------------------
irq:								

    rti								;fin de la interrupción



;--------------- VECTOR TABLE ------------------------
    .org $bffa
    .dw  nmi						;apunta a int. VBlank
    .dw  reset						;apunta al inicio del programa
    .dw  irq						;apunta a int IRQ






;------------------------------------------------------
;---------------- CHR ROM -----------------------------
;------------------------------------------------------
    .incbin "CHR/font.chr" 		;4kb
    .incbin "CHR/font.chr" 		;4kb
    
    
