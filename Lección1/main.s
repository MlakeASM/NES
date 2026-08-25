	.INCLUDE "Includes/Registros.i"

;---------------- HEADER ---------------------------------------------------
    PRG_COUNT	= 1 	;1 	= 16KB, 2 = 32KB, 3 = 48KB.... (16KB)
	CHR_COUNT	= 1 	;1 	= 8KB, 2 = 16KB, 4 = 32KB....  (8KB)
	INES_MAPPER = 0 	;0  = No mapper
    INES_MIRROR = 1 	;0 	= horizontal mirroring, 1 = vertical mirroring
    INES_SRAM   = 0 	;1 	= SRAM $6000->$7FFF (8KB)
	INES_REGION	= 1		;0 	= NTSC    1 = PAL

	.db 'N', 'E', 'S', $1A 			;ID 
	.db PRG_COUNT 					;número de bloques PRG-ROM de 16KB
	.db CHR_COUNT 					;número de bloques CHR-ROM de 16KB
	
	
	.db ((INES_MAPPER & $0f) << 4) | (INES_SRAM << 1) | INES_MIRROR 
	; 76543210
	; ||||||||
	; |||||||+- Nametable: 0: scroll vertical ("horizontal mirrored") 
	; |||||||              1: scroll horizontal ("vertically mirrored")
	; ||||||+-- 1: PRG RAM ($6000-7FFF)
	; |||||+--- 1: 512-byte trainer at $7000-$71FF (stored before PRG data)
	; ||||+---- 1: Alternative nametable layout
	; ++++----- Número de mapper (parte baja $0X)
	
	
	.db (INES_MAPPER & $f0)
	; 76543210
	; ||||||||
	; |||||||+- VS Unisystem
	; ||||||+-- PlayChoice-10 (8 KB of Hint Screen data stored after CHR data)
	; ||||++--- If equal to 2, flags 8-15 are in NES 2.0 format
	; ++++----- Número de mapper (parte alta $X0)
	
	.db $0							;numero de bloques de PRG RAM de 8KB
	
	.db	INES_REGION & $1			;Región
	; 76543210
	; ||||||||
	; |||||||+- TV system (0: NTSC; 1: PAL)
	; +++++++-- Reservado, poner a cero


	.db $0, $0, $0, $0, $0, $0 		;padding



;-----------------------------------------------------------------
;--------------------------- CHR ROM -----------------------------
;-----------------------------------------------------------------

;------------------ 16KB bank C000-FFFA --------------------------
	.base	$c000
	
reset:

 	sei							;Interrupciones OFF
	cld							;Decimales OFF
	
	
	
	;Desactiva interrupciones APU
	ldx #$40					
	stx APUFRAME				;APUFRAME ($4017)
	; 7654 3210
	; MIxx xxxx
	; |+----------------------- Bloquear interrupcion  1=si, 0=no
	; +------------------------ Modo

	ldx #$00
	stx DMCFREQ					;DMC ($4010)
	; 7654 3210
	; ILxx FFFF
	; ||   ++++---------------- Frecuencia sample
	; |+----------------------- Loop  1=si, 0=no
	; +------------------------ Interrupcion  1=si, 0=no


	ldx #$ff					;inicia Pila
	txs
								;Limpia PPU
	ldx #0						;X = 0
	stx PPUCTRL					;PPUCTRL y PPUMASK se explican despues.
	stx PPUCTRL
	stx PPUMASK

	jsr waitvb					;Esperar VBlank
	
	
	lda #0						;A = 0
ClearMEM:						;limpia RAM $0-$7ff (2KB)
		sta $0,x				;X = offset
		sta $100,x				
		sta $200,x
		sta $300,x
		sta $400,x
		sta $500,x
		sta $600,x
		sta $700,x
	inx							;incrementa offset (X)
	bne ClearMEM				;si X no ha dado la vuelta ($00), volvemos

	jsr waitvb					;esperar VBlank
	
	cli							;Encender interrupciones
	lda #$80					
	sta PPUCTRL					;PPUCTL ($2000)
	; 7654 3210
	; VPHB SINN
	; |||| ||||
	; |||| ||++- Direccion nametable
	; |||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
	; |||| |+--- incremento al escribir en PPUDATA
	; |||| |     (0: añadir 1, 1: añadir 32)
	; |||| +---- Direccion Sprite pattern table 8x8 sprites
	; ||||       (0: $0000; 1: $1000; ignorado in 8x16 mode)
	; |||+------ Background pattern table address (0: $0000; 1: $1000)
	; ||+------- Tamaño Sprites (0: 8x8 pixels; 1: 8x16 pixels)
	; |+-------- PPU master/slave select (siempre a 0, poner 1 daña hardware)
	; +--------- Vblank NMI (0: off, 1: on)
	
	lda #$08
	sta PPUMASK						;PPUMASK ($2001)
	; 7654 3210
	; BGRs bMmG
	; |||| ||||	
	; |||| |||+- (0: color, 1: blanco y negro)
	; |||| ||+-- 1: mostrar los primeros 8 pixels del fondo lado izdo, 0: ocultarlos
	; |||| |+--- 1: mostrar los primeros 8 pixels de sprites lado izdo, 0: ocultarlos
	; |||| +---- 1: Dibujar fondo, 0: Ocultar fondo 
	; |||+------ 1: Dibujar sprites, 0: Ocultar sprites
	; ||+------- Enfatizar ROJO (VERDE en PAL/Dendy)
	; |+-------- Enfatizar VERDE (ROJO on PAL/Dendy)
	; +--------- Enfatizar AZUL 
	
	
	PPU_Paletas = $3f00
				
									
	lda #>PPU_Paletas				;mete parte alta $3f
	sta PPUADDR						;PPUADDR ($2006) 
	lda #<PPU_Paletas				;mete parte baja $00
	sta PPUADDR						;PPUADDR ($2006) 
	
	ldx #0
LoadPaleta:
	lda PaletaF0,x
	sta PPUDATA						;PPUDATA ($2007)
	inx
	cpx #32
	bne LoadPaleta
	
	
;--------------- MAINLOOP ----------------------------

MainLoop:

	jmp MainLoop					;salta a MainLoop



;------------------ DATOS ----------------------------
									;Transparecia + 3colores

PaletaF0:	 .db $3f,$2d,$3d,$30	;Paleta Fondo 0
PaletaF1:	 .db $3f,$11,$21,$31	;Paleta Fondo 1
PaletaF2:	 .db $3f,$13,$23,$33	;Paleta Fondo 2	
PaletaF3:	 .db $3f,$14,$24,$34	;Paleta Fondo 3

									;El color 0 de "Paleta Sprites 0"
									;va a ser el color de fondo/transparencia
PaletaS0:	 .db $3f,$19,$29,$39	;Paleta Sprites 0	
PaletaS1:	 .db $3f,$18,$28,$38	;Paleta Sprites 1	
PaletaS2:	 .db $3f,$16,$26,$36	;Paleta Sprites 2	
PaletaS3:	 .db $3f,$1c,$2c,$3c	;Paleta Sprites 3	


;---------------- RUTINAS ----------------------------

waitvb:								;Espera VBlank
	bit PPUSTATUS
	
	; 7654 3210
	; Vxxx xxxx
	; |
	; +--------- Vblank flag
	
	bpl waitvb						;salto a waitvb si el bit 7 es 0
	rts



;--------------- VBI int -----------------------------
nmi:	

	rti								;fin de la interrupción


;--------------- IRQ int -----------------------------
irq:								;IRQ vacia

    rti								;fin de la interrupción



;--------------- VECTOR TABLE ------------------------
    .org $fffa
    .dw  nmi						;apunta a int. VBlank
    .dw  reset						;apunta al inicio del programa
    .dw  irq						;apunta a int IRQ






;------------------------------------------------------
;---------------- CHR ROM -----------------------------
;------------------------------------------------------
    .incbin "CHR/font.chr" 		;4kb
    .incbin "CHR/font.chr" 		;4kb
    
    
