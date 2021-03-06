;
; Snake.asm
;
; Created: 2019-04-25 13:47:41
; Author : Jonna, Mike, Erik & Simon
;
/* 
	SelfCollision sitter i en loop
*/

.DEF end = r16
.DEF temp1 = r17
.DEF temp2 = r18
.DEF temp3 = r19
.DEF temp4 = r20
.DEF updateGame = r21
.DEF loopcounter = r22
.DEF totalLength = r23
.DEF length = r24
.DEF direction = r25
; random generator = r26

.DSEG
snakebody:		.BYTE 64
matrix:			.BYTE 8

.CSEG
.ORG 0x0000
	jmp init
	nop
.ORG 0x0020
	jmp gameUpdateTimer
	nop

init:
	// Enable DDR registers
    ldi r16, 0b00011111
    out DDRC, r16
    ldi r16, 0b11111100
    out DDRD, r16
    ldi r16, 0b00111111
    out DDRB, r16

	// Pointers to matrix (snake)
	ldi ZH, HIGH(snakebody)
	ldi ZL, LOW(snakebody)
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	ldi length, 4
	mov totalLength, length
	inc totalLength
	ldi loopcounter, 0
	ldi direction, 0b00000001
	
	// Snake head
	ldi temp1, 0b01000100
	st Z, temp1
	ldi temp1, 0b00110100
	std Z+1, temp1
	ldi temp1, 0b00100100
	std Z+2, temp1	
	ldi temp1, 0b00010100
	std Z+3, temp1

	//Food
	call locateFood
	nop

	// Matrix
	st Y, r1
	std Y+1, r1
	std Y+2, r1
	std Y+3, r1
	std Y+4, r1
	std Y+5, r1
	std Y+6, r1
	std Y+7, r1
	
	// Enable Joystick
	ldi		temp1, 0b01100000
	sts		ADMUX, temp1
   	ldi		temp1, 0b10000111
   	sts		ADCSRA, temp1

	// Set stack pointer
	ldi		temp1, HIGH(RAMEND)
    out		SPH, temp1
    ldi		temp1, LOW(RAMEND)
    out		SPL, temp1

	// Timer
	sei
	lds		temp1, TCCR0B
	ori		temp1, 0b00000110
	sts		0x45, temp1

    ldi		temp1, (1<<TOIE0)
    lds		temp2, TIMSK0
    or		temp1, temp2
    sts		TIMSK0, temp1

resetAndDraw:
	ldi temp1, 0
	ldi temp2, 0
	ldi temp3, 0
	ldi temp4, 0
	ldi end, 0
	ldi updateGame, 0
	ldi loopcounter, 0
	jmp drawMatrix
	nop
main:
	call updatesnake
	nop
	jmp resetAndDraw			// Draws matrix, jumps back to main. *Do this last*
	nop
updatesnake:
	cpi updateGame, 1			// Check if it's time to update (controlled by interrupts)
	brne returntomain
	call resetMatrix			// Reset matrix before calculating new positions
	nop
	call joystickinput			// Listen to input. This modifies values in Z
	nop
	call detectCollision		// Check for head/food collision
	nop
	call checkSelfCollision		// Check for self-collision
	nop
	call moveBody				// Move body relative to head
	nop	
	call translatePositions		// Translates coordinates (Z) to matrix (Y)
	nop
	ldi updateGame, 0			// Reset flag to update game
returntomain:
	ret
	nop
moveBody:						// Update body relative to previous head position
	;Skip head and place pointer on body
	ld temp1, Z+
	;Decrement length since we're skipping head (restoring on exit to main)
	push length
	dec length
	bodyLoop:	
		cp length, loopcounter
		breq exitupdate
		ld temp1, Z
		st Z+, temp3
		mov temp3, temp1
		inc loopcounter	
		jmp bodyLoop
		nop
	exitupdate:
		ldi loopcounter, 0
		pop length
		ldi ZL, LOW(snakebody)
		ret
		nop
checkSelfCollision:				// Iterates through body and sees if head collides
	ld temp1, Z+
	ldi loopcounter, 2			
	collisionLoop:
		cp length, loopcounter
		breq noCollision
		ld temp2, Z+
		cp temp1, temp2
		breq collisionFound
		nop
		jmp cIncrement
		nop
	cIncrement:
		inc loopcounter
		jmp collisionLoop
		nop
	collisionFound:
		call resetMatrix
		nop
		jmp collisionFound
		nop
		//jmp gameOver
		//nop 
	noCollision:
		ldi loopcounter, 0
		ldi ZL, LOW(snakebody)
		ret
		nop
translatePositions:				// Iterates through Z (positions) to translate into matrix
	cp totalLength, loopcounter
	breq exit2
	nop
	ld temp1, Z+				// Load position from Z and post increment pointer
	mov temp2, temp1
	andi temp2, 0b11110000		// Mask out X-value (first 4 bits)
	lsr temp2					// Shift 4 steps right to make compares easier
	lsr temp2
	lsr temp2
	lsr temp2
	cpi temp2, 0
	breq X_0
	nop
	cpi temp2, 1
	breq X_1
	nop
	cpi temp2, 2
	breq X_2
	nop
	cpi temp2, 3
	breq X_3
	nop
	cpi temp2, 4
	breq X_4
	nop
	cpi temp2, 5
	breq X_5
	nop
	cpi temp2, 6
	breq X_6
	nop
	cpi temp2, 7
	breq X_7
	nop
	exit1:
	subi loopcounter, -1	// increment i
	jmp translatePositions
	nop
	exit2:
	ldi ZL, LOW(snakebody)	// reset pointer before returning to main
	ret
	nop
	X_0:
	ldi temp3, 0b00000001
	jmp calcYPos
	nop
	X_1:
	ldi temp3, 0b00000010
	jmp calcYPos
	nop	
	X_2:
	ldi temp3, 0b00000100
	jmp calcYPos
	nop
	X_3:
	ldi temp3, 0b00001000
	jmp calcYPos
	nop
	X_4:
	ldi temp3, 0b00010000
	jmp calcYPos
	nop
	X_5:
	ldi temp3, 0b00100000
	jmp calcYPos
	nop
	X_6:
	ldi temp3, 0b01000000
	jmp calcYPos
	nop
	X_7:
	ldi temp3, 0b10000000
	jmp calcYPos
	nop
	calcYPos:					// Calculate which Y position in matrix to draw to
	mov temp4, temp1
	andi temp4, 0b00001111
	cpi temp4, 0
	breq Y_0
	nop
	cpi temp4, 1
	breq Y_1
	nop
	cpi temp4, 2
	breq Y_2
	nop
	cpi temp4, 3
	breq Y_3
	nop
	cpi temp4, 4
	breq Y_4
	nop
	cpi temp4, 5
	breq Y_5
	nop
	cpi temp4, 6
	breq Y_6
	nop
	cpi temp4, 7
	breq Y_7
	nop 
	Y_0:						// Save previous value of matrix row and insert new
	ld temp4, Y
	or temp3, temp4
	st Y, temp3
	jmp exit1
	nop
	Y_1:
	ldd temp4, Y+1
	or temp3, temp4
	std Y+1, temp3
	jmp exit1
	nop
	Y_2:
	ldd temp4, Y+2
	or temp3, temp4
	std Y+2, temp3
	jmp exit1
	nop
	Y_3:
	ldd temp4, Y+3
	or temp3, temp4
	std Y+3, temp3
	jmp exit1
	nop
	Y_4:
	ldd temp4, Y+4
	or temp3, temp4
	std Y+4, temp3
	jmp exit1
	nop
	Y_5:
	ldd temp4, Y+5
	or temp3, temp4
	std Y+5, temp3
	jmp exit1
	nop
	Y_6:
	ldd temp4, Y+6
	or temp3, temp4
	std Y+6, temp3
	jmp exit1
	nop
	Y_7:
	ldd temp4, Y+7
	or temp3, temp4
	std Y+7, temp3
	jmp exit1
	nop
drawMatrix:
/*Begin drawing one row at a time. Load in value from matrix and make compares.
Depending on value of row, the bits will translate correctly and be saved in register "end"
Finally, each row outputs "end" to corresponding port*/
calcrow_0:			
	ld temp1, Y
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_0
	nop
	ldi temp2, 0b01000000
	neg temp2
	sub end, temp2
	subi temp1, 0b10000000
calc64_0:
	cpi temp1, 0b01000000
	brlo calc32_0
	nop
	ldi temp2, 0b10000000
	neg temp2
	sub end, temp2
	subi temp1, 0b01000000
calc32_0:
	cpi temp1, 0b00100000
	brlo calc16_0
	nop
	ldi temp2, 0b00000001
	neg temp2
	sub end, temp2
	subi temp1, 0b00100000
calc16_0:
	cpi temp1, 0b00010000
	brlo calc8_0
	nop
	ldi temp2, 0b00000010
	neg temp2
	sub end, temp2
	subi temp1, 0b00010000
calc8_0:
	cpi temp1, 0b00001000
	brlo calc4_0
	nop
	ldi temp2, 0b00000100
	neg temp2
	sub end, temp2
	subi temp1, 0b00001000
calc4_0:
	cpi temp1, 0b00000100
	brlo calc2_0
	nop
	ldi temp2, 0b00001000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000100
calc2_0:
	cpi temp1, 0b00000010
	brlo calc1_0
	nop
	ldi temp2, 0b00010000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000010
calc1_0:
	cpi temp1, 0b00000001
	brlo outputrow_0
	nop
	ldi temp2, 0b00100000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000001
outputrow_0:
	ldi temp1, 0b00000001
	out PORTC, temp1
	mov temp1, end
	ANDI temp1, 0b11000000
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	nop
	ldi temp3, 0b00110000
	out PORTC, temp3
	out PORTD, r1
	out PORTB, r1
calcrow_1:
	ldd temp1, Y+1
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_1
	nop
	ldi temp2, 0b01000000
	neg temp2
	sub end, temp2
	subi temp1, 0b10000000
calc64_1:
	cpi temp1, 0b01000000
	brlo calc32_1
	nop
	ldi temp2, 0b10000000
	neg temp2
	sub end, temp2
	subi temp1, 0b01000000
calc32_1:
	cpi temp1, 0b00100000
	brlo calc16_1
	nop
	ldi temp2, 0b00000001
	neg temp2
	sub end, temp2
	subi temp1, 0b00100000
calc16_1:
	cpi temp1, 0b00010000
	brlo calc8_1
	nop
	ldi temp2, 0b00000010
	neg temp2
	sub end, temp2
	subi temp1, 0b00010000
calc8_1:
	cpi temp1, 0b00001000
	brlo calc4_1
	nop
	ldi temp2, 0b00000100
	neg temp2
	sub end, temp2
	subi temp1, 0b00001000
calc4_1:
	cpi temp1, 0b00000100
	brlo calc2_1
	nop
	ldi temp2, 0b00001000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000100
calc2_1:
	cpi temp1, 0b00000010
	brlo calc1_1
	nop
	ldi temp2, 0b00010000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000010
calc1_1:
	cpi temp1, 0b00000001
	brlo outputrow_1
	nop
	ldi temp2, 0b00100000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000001
outputrow_1:
	ldi temp1, 0b00000010
	out PORTC, temp1
	mov temp1, end
	ANDI temp1, 0b11000000
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	nop
	out PORTC, temp3
	out PORTD, r1
	out PORTB, r1
calcrow_2:
	ldd temp1, Y+2
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_2
	nop
	ldi temp2, 0b01000000
	neg temp2
	sub end, temp2
	subi temp1, 0b10000000
calc64_2:
	cpi temp1, 0b01000000
	brlo calc32_2
	nop
	ldi temp2, 0b10000000
	neg temp2
	sub end, temp2
	subi temp1, 0b01000000
calc32_2:
	cpi temp1, 0b00100000
	brlo calc16_2
	nop
	ldi temp2, 0b00000001
	neg temp2
	sub end, temp2
	subi temp1, 0b00100000
calc16_2:
	cpi temp1, 0b00010000
	brlo calc8_2
	nop
	ldi temp2, 0b00000010
	neg temp2
	sub end, temp2
	subi temp1, 0b00010000
calc8_2:
	cpi temp1, 0b00001000
	brlo calc4_2
	nop
	ldi temp2, 0b00000100
	neg temp2
	sub end, temp2
	subi temp1, 0b00001000
calc4_2:
	cpi temp1, 0b00000100
	brlo calc2_2
	nop
	ldi temp2, 0b00001000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000100
calc2_2:
	cpi temp1, 0b00000010
	brlo calc1_2
	nop
	ldi temp2, 0b00010000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000010
calc1_2:
	cpi temp1, 0b00000001
	brlo outputrow_2
	nop
	ldi temp2, 0b00100000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000001
outputrow_2:
	ldi temp1, 0b00000100
	out PORTC, temp1
	mov temp1, end
	ANDI temp1, 0b11000000
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	nop
	out PORTC, temp3
	out PORTD, r1
	out PORTB, r1
calcrow_3:
	ldd temp1, Y+3
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_3
	nop
	ldi temp2, 0b01000000
	neg temp2
	sub end, temp2
	subi temp1, 0b10000000
calc64_3:
	cpi temp1, 0b01000000
	brlo calc32_3
	nop
	ldi temp2, 0b10000000
	neg temp2
	sub end, temp2
	subi temp1, 0b01000000
calc32_3:
	cpi temp1, 0b00100000
	brlo calc16_3
	nop
	ldi temp2, 0b00000001
	neg temp2
	sub end, temp2
	subi temp1, 0b00100000
calc16_3:
	cpi temp1, 0b00010000
	brlo calc8_3
	nop
	ldi temp2, 0b00000010
	neg temp2
	sub end, temp2
	subi temp1, 0b00010000
calc8_3:
	cpi temp1, 0b00001000
	brlo calc4_3
	nop
	ldi temp2, 0b00000100
	neg temp2
	sub end, temp2
	subi temp1, 0b00001000
calc4_3:
	cpi temp1, 0b00000100
	brlo calc2_3
	nop
	ldi temp2, 0b00001000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000100
calc2_3:
	cpi temp1, 0b00000010
	brlo calc1_3
	nop
	ldi temp2, 0b00010000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000010
calc1_3:
	cpi temp1, 0b00000001
	brlo outputrow_3
	nop
	ldi temp2, 0b00100000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000001
outputrow_3:
	ldi temp1, 0b00001000
	out PORTC, temp1
	mov temp1, end
	ANDI temp1, 0b11000000
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	nop
calcrow_4:
	ldd temp1, Y+4
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_4
	nop
	ldi temp2, 0b01000000
	neg temp2
	sub end, temp2
	subi temp1, 0b10000000
calc64_4:
	cpi temp1, 0b01000000
	brlo calc32_4
	nop
	ldi temp2, 0b10000000
	neg temp2
	sub end, temp2
	subi temp1, 0b01000000
calc32_4:
	cpi temp1, 0b00100000
	brlo calc16_4
	nop
	ldi temp2, 0b00000001
	neg temp2
	sub end, temp2
	subi temp1, 0b00100000
calc16_4:
	cpi temp1, 0b00010000
	brlo calc8_4
	nop
	ldi temp2, 0b00000010
	neg temp2
	sub end, temp2
	subi temp1, 0b00010000
calc8_4:
	cpi temp1, 0b00001000
	brlo calc4_4
	nop
	ldi temp2, 0b00000100
	neg temp2
	sub end, temp2
	subi temp1, 0b00001000
calc4_4:
	cpi temp1, 0b00000100
	brlo calc2_4
	nop
	ldi temp2, 0b00001000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000100
calc2_4:
	cpi temp1, 0b00000010
	brlo calc1_4
	nop
	ldi temp2, 0b00010000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000010
calc1_4:
	cpi temp1, 0b00000001
	brlo outputrow_4
	nop
	ldi temp2, 0b00100000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000001
outputrow_4:
	out PORTC, r1
	mov temp1, end
	ANDI temp1, 0b11000000
	ORI temp1, 0b00000100
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	nop
	out PORTC, temp3
	out PORTD, r1
	out PORTB, r1
calcrow_5:
	ldd temp1, Y+5
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_5
	nop
	ldi temp2, 0b01000000
	neg temp2
	sub end, temp2
	subi temp1, 0b10000000
calc64_5:
	cpi temp1, 0b01000000
	brlo calc32_5
	nop
	ldi temp2, 0b10000000
	neg temp2
	sub end, temp2
	subi temp1, 0b01000000
calc32_5:
	cpi temp1, 0b00100000
	brlo calc16_5
	nop
	ldi temp2, 0b00000001
	neg temp2
	sub end, temp2
	subi temp1, 0b00100000
calc16_5:
	cpi temp1, 0b00010000
	brlo calc8_5
	nop
	ldi temp2, 0b00000010
	neg temp2
	sub end, temp2
	subi temp1, 0b00010000
calc8_5:
	cpi temp1, 0b00001000
	brlo calc4_5
	nop
	ldi temp2, 0b00000100
	neg temp2
	sub end, temp2
	subi temp1, 0b00001000
calc4_5:
	cpi temp1, 0b00000100
	brlo calc2_5
	nop
	ldi temp2, 0b00001000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000100
calc2_5:
	cpi temp1, 0b00000010
	brlo calc1_5
	nop
	ldi temp2, 0b00010000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000010
calc1_5:
	cpi temp1, 0b00000001
	brlo outputrow_5
	nop
	ldi temp2, 0b00100000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000001
outputrow_5:
	mov temp1, end
	ANDI temp1, 0b11000000
	ORI temp1, 0b00001000
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	nop
	out PORTC, temp3
	out PORTD, r1
	out PORTB, r1
calcrow_6:
	ldd temp1, Y+6
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_6
	nop
	ldi temp2, 0b01000000
	neg temp2
	sub end, temp2
	subi temp1, 0b10000000
calc64_6:
	cpi temp1, 0b01000000
	brlo calc32_6
	nop
	ldi temp2, 0b10000000
	neg temp2
	sub end, temp2
	subi temp1, 0b01000000
calc32_6:
	cpi temp1, 0b00100000
	brlo calc16_6
	nop
	ldi temp2, 0b00000001
	neg temp2
	sub end, temp2
	subi temp1, 0b00100000
calc16_6:
	cpi temp1, 0b00010000
	brlo calc8_6
	nop
	ldi temp2, 0b00000010
	neg temp2
	sub end, temp2
	subi temp1, 0b00010000
calc8_6:
	cpi temp1, 0b00001000
	brlo calc4_6
	nop
	ldi temp2, 0b00000100
	neg temp2
	sub end, temp2
	subi temp1, 0b00001000
calc4_6:
	cpi temp1, 0b00000100
	brlo calc2_6
	nop
	ldi temp2, 0b00001000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000100
calc2_6:
	cpi temp1, 0b00000010
	brlo calc1_6
	nop
	ldi temp2, 0b00010000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000010
calc1_6:
	cpi temp1, 0b00000001
	brlo outputrow_6
	nop
	ldi temp2, 0b00100000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000001
outputrow_6:
	mov temp1, end
	ANDI temp1, 0b11000000
	ORI temp1, 0b00010000
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	nop
	out PORTC, temp3
	out PORTD, r1
	out PORTB, r1
calcrow_7:
	ldd temp1, Y+7
	ldi end, 0b00000000
	cpi temp1, 0b10000000
	brlo calc64_7
	nop
	ldi temp2, 0b01000000
	neg temp2
	sub end, temp2
	subi temp1, 0b10000000
calc64_7:
	cpi temp1, 0b01000000
	brlo calc32_7
	nop
	ldi temp2, 0b10000000
	neg temp2
	sub end, temp2
	subi temp1, 0b01000000
calc32_7:
	cpi temp1, 0b00100000
	brlo calc16_7
	nop
	ldi temp2, 0b00000001
	neg temp2
	sub end, temp2
	subi temp1, 0b00100000
calc16_7:
	cpi temp1, 0b00010000
	brlo calc8_7
	nop
	ldi temp2, 0b00000010
	neg temp2
	sub end, temp2
	subi temp1, 0b00010000
calc8_7:
	cpi temp1, 0b00001000
	brlo calc4_7
	nop
	ldi temp2, 0b00000100
	neg temp2
	sub end, temp2
	subi temp1, 0b00001000
calc4_7:
	cpi temp1, 0b00000100
	brlo calc2_7
	nop
	ldi temp2, 0b00001000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000100
calc2_7:
	cpi temp1, 0b00000010
	brlo calc1_7
	nop
	ldi temp2, 0b00010000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000010
calc1_7:
	cpi temp1, 0b00000001
	brlo outputrow_7
	nop
	ldi temp2, 0b00100000
	neg temp2
	sub end, temp2
	subi temp1, 0b00000001
outputrow_7:
	mov temp1, end
	ANDI temp1, 0b11000000
	ORI temp1, 0b00100000
	out PORTD, temp1
	mov temp1, end
	ANDI temp1, 0b00111111
	out PORTB, temp1
	call delay1
	nop
	out PORTC, temp3
	out PORTD, r1
	out PORTB, r1
	jmp main
	nop
	;Draw matrix ends
joystickinput:		//Listen to joystick (X-axis first)
	ldi		temp1, 0b00000101		
	lds		temp2, ADMUX
	andi	temp2, 0b11111000
	or		temp2, temp1
	sts		ADMUX, temp2

	ldi		temp1, (1<<ADSC)
	lds		temp2, ADCSRA
	or		temp2, temp1
	sts		ADCSRA, temp2
wait1:
	;Wait until "read" is finished (bit 6 = 0)
	lds temp2, ADCSRA
	sbrc temp2, ADSC
	jmp wait1
	nop
	lds temp3, ADCH
	add r26, temp3
	jmp joyinputY
	nop

joyinputY:				//Listen to joystick (Y-axis)
	ldi		temp1, 0b00000100			
	lds		temp2, ADMUX
	andi	temp2, 0b11111000
	or		temp2, temp1
	sts		ADMUX, temp2

	ldi		temp1, (1<<ADSC)
	lds		temp2, ADCSRA
	or		temp2, temp1
	sts		ADCSRA, temp2	
wait2:
	;Same as wait1 but with up/down motion
	lds temp2, ADCSRA
	sbrc temp2, ADSC
	jmp wait2
	nop
	lds temp4, ADCH
	add r26, temp4 ;for random spawn point

	jmp compareinput
	nop
east:
	cpi direction, 0b00000010
	breq moveWest
	nop
	ldi direction, 0b00000001
	jmp calcDirection
	nop
moveEast:					
	ld temp1, Z
	mov temp3, temp1
	cpi temp1, 16
	brlo wrapAroundEast
	nop
	subi temp1, 16
	st Z, temp1
	jmp exitinput
	nop
wrapAroundEast:
	ori temp1, 0b01110000
	st Z, temp1
	jmp exitinput
	nop
west:
	cpi direction, 0b00000001
	breq moveEast
	nop
	ldi direction, 0b00000010
	jmp calcDirection 
	nop
moveWest:                   ;Move sideways = read old position of head,
    ld temp1, Z             ;subtract/add LSB of X position (bit value 16), 
    mov temp3, temp1		;then insert new value back to Z
    cpi temp1, 112            
    brsh wrapAroundWest
    nop
    subi temp1, -16            
    st Z, temp1
    jmp exitinput
    nop
wrapAroundWest:
    andi temp1, 0b00001111
    st Z, temp1
    jmp exitinput
    nop
compareinput:	;Compare input and branch accordingly. Set direction
	cpi temp3, 140
	brsh east
	nop
	cpi temp3, 5
	brlo west
	nop	
	cpi temp4, 40
	brsh north
	nop
	cpi temp4, 1
	brlo south 
	nop
	jmp exitinput			;Exit if no input 
	nop
north:
	cpi direction, 0b00000100
	breq moveSouth
	nop	
	ldi direction, 0b00001000
	jmp calcDirection
	nop
moveNorth:					;Move upwards/downwards = read old position,
	ld temp1, Z				;subtract/add LSB of Y position (bit value 1),
	mov temp3, temp1
	mov temp2, temp1		;then insert new value back to Z
	andi temp2, 0b00001111
	cpi temp2, 0
	breq wrapAroundNorth
	nop	
	subi temp1, 1
	st Z, temp1
	jmp exitinput
	nop
wrapAroundNorth:
	ldi temp2, 0b00000111
	andi temp1, 0b01110000
	or temp1, temp2
	st Z, temp1
	jmp exitinput
	nop
south:
	cpi direction, 0b00001000
	breq moveNorth
	nop
	ldi direction, 0b00000100
	jmp calcDirection
	nop
moveSouth:
	ld temp1, Z
	mov temp3, temp1
	mov temp2, temp1
	andi temp2, 0b00001111
	cpi temp2, 7
	breq wrapAroundSouth
	nop
	subi temp1, -1
	st Z, temp1
	jmp exitinput
	nop
wrapAroundSouth:
	andi temp1, 0b01110000
	or temp1, r1
	st Z, temp1
	jmp exitinput
	nop
exitinput:					;Reset input and go back to main after moving
	ret
calcDirection:				;Checks value of "direction" and moves snake's head accordingly
	sbrc direction, 0
	jmp moveWest
	nop
	sbrc direction, 1
	jmp moveEast
	nop
	sbrc direction, 2
	jmp moveSouth
	nop
	sbrc direction, 3
	jmp moveNorth
	nop
	jmp exitinput
	nop




resetMatrix:				;Reset matrix
	st Y, r1
    std Y+1, r1
    std Y+2, r1
    std Y+3, r1
    std Y+4, r1
    std Y+5, r1
    std Y+6, r1
    std Y+7, r1
	ret
	nop
delay1:						;Delay called after each output
    ldi  temp3, 13
    ldi  temp4, 252
	L1:	dec  temp4
		brne L1
		dec  temp3
		brne L1
		ret
		nop
detectCollision:
		ld temp1, Z ;head
	getApple:
		cp totalLength, loopcounter
		brne dIncrement
		nop
		ld temp2, -Z ;food
		cp temp1, temp2
		breq grow
		nop
		jmp exitDetection
		nop
	dIncrement:
		ld temp2, Z+
		inc loopcounter
		jmp getApple
		nop 
	grow:
		inc length
		call syncLength
		nop	
		ldi loopcounter, 0
		ldi ZL, LOW(snakebody)
		jmp locateFood 
		nop
	exitDetection:
		ldi loopcounter, 0
		ldi ZL, LOW(snakebody)
		ret
		nop
locateFood:
	;Pick a "random" position within the grid	
	 mov temp1, r26
	 andi temp1, 0b01110111 ;Convert to coordinate
	 locationLoop:
	 ;Compare to snake
	 ld temp2, Z+
	 cp temp1, temp2
	 
	 ;If collision found
	 breq pickNewValue
	 nop

	 cp length, loopcounter
	 breq foundFoodLocation
	 nop
	 inc loopcounter
	 jmp locationLoop
	 nop
	 pickNewValue:
		lds temp2, ADCH
		add temp1, temp2
		com temp1
		andi temp1, 0b01110111
		ldi loopcounter, 0
		ldi ZL, LOW(snakebody)
		jmp locationLoop
		nop
	 foundFoodLocation:
		ldi loopcounter, 0
		ldi ZL, LOW(snakebody)
		jmp insertNewFoodPosition
		nop

insertNewFoodPosition:
		;Routine for inserting the new position into game matrix
		;(Food is placed in last)
		cp totalLength, loopcounter
		brne increment
		st Z, temp1
		jmp exitLocate
		nop
	increment:
		ld temp2, Z+
		inc loopcounter
		jmp insertNewFoodPosition
		nop
	exitLocate:
		ldi ZL, LOW(snakebody)
		ldi loopcounter, 0
		ret
		nop
gameUpdateTimer:		; Flag set by interrupt to update game
	ldi updateGame, 0b00000001
	reti
	nop
syncLength:				; Called each time length is incremented
	mov totalLength, length
	inc totalLength
	ret
	nop
gameOver:
	call resetMatrix
	nop
	jmp gameOver
	nop

/* iterate
	detectLoop:
		cp totalLength, loopcounter
		brne dIncrement
		
		ret
		nop
	dIncrement:
		inc loopcounter
		jmp detectLoop
		nop 
*/

/*	
	gammal sheet
	uniquePosition: 
		;Cycle until food does not collide with snake
		;If no part of snake collides with food, insert the new position into food matrix
		;If snake collides with food, pick a new position (based on ADCH and multiplication)
		cp length, loopcounter
		breq validPosition
		nop
		inc temp1
		mul temp2, temp1
		andi temp2, 0b00000111
		andi temp1, 0b01110000
		or temp1, temp2
		ld temp2, Z+
		cp temp2, temp1
		breq uniquePosition
		nop

		jmp uniquePosition
		nop
	iterateBody:
		;Iterate through every body part and compare it to the potential food position
		cp length, loopcounter
		breq validPosition
		nop
		ld temp2, Z+
		;See if they collide 
		cp temp2, temp1
		brne uIncrement
		nop
		;Pick a new position and reset loop counter + pointer
		ldi ZL, LOW(snakebody)
		ldi loopcounter, 0
		jmp uniquePosition
		nop
	uIncrement:
		inc loopcounter
		jmp iterateBody
		nop
	validPosition:
		ldi ZL, LOW(snakebody)
		ldi loopcounter, 0
		jmp insertNewFoodPosition
		nop
*/