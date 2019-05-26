;
; Snake.asm
;
; Created: 2019-04-25 13:47:41
; Author : Jonna, Mike, Erik & Simon
;
/* Changelog
	Simon 25/5:
	-Skapade subrutiner för rörelse (moveSouth etc)
	-Skapade game loop
	-Tog bort calcHeadPosition eftersom vi inte längre behöver kolla vilken rad huvudet befinner sig på
	-Ändrade värden i ADMUX, gamla värden finns utkommenterade längst ner,
	 (ändrade även init, gamla koden finns utkommenterad)

	To-do:
	-Flytta ormen: spara ner gamla positionen innan den skrivs över så nästa "kroppsdel" kan ärva
	-Räknare/pekare för att hålla koll på kanterna?
	-Huvudet tar alltid ett steg till vänster (börjar på X-pos 0000) och står sedan stilla
	-Timers?

	*/

.DEF end = r16
.DEF temp1 = r17
.DEF temp2 = r18
.DEF temp3 = r19
.DEF temp4 = r20
.DEF updateGame = r21
.DEF loopcounter = r22
.DEF food = r23
.DEF length = r24
.DEF direction = r25

.DSEG
snakebody:		.BYTE 16
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
	ldi food, 0
	ldi loopcounter, 0
	
	// Snake head
	ldi temp1, 0b00000100
	st Z, temp1
	
	/*
	ldi temp1, 0b01100100
	std Z+1, temp1
	ldi temp1, 0b01010100
	std Z+2, temp1	
	ldi temp1, 0b01000100
	std Z+3, temp1*/

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
	sts		ADMUX,temp1
   	ldi		temp1,0b10000111
   	sts		ADCSRA,temp1

/*	ldi r16, 0b01100000
	lds temp1, ADMUX
	or r16, temp1
	sts ADMUX, r16
	ldi r16, 0b10000111
	lds temp1, ADCSRA
	or r16, temp1
	sts ADCSRA, r16
*/
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
	ldi ZH, HIGH(snakebody)
	ldi ZL, LOW(snakebody)
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)

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
	//call joystickinput		// Listen to input. This modifies values in Z
	//nop
	call resetMatrix //tmp
	nop
	call translatePositions		// Translates coordinates (Z) to matrix (Y)
	nop
	call movedot
	nop
	ldi updateGame, 0			// Reset flag to update game
returntomain:
	ret
	nop
movedot:
	ldi ZL, LOW(snakebody)
	ld temp1, Z
	std Y+1, temp1 //tmp
	subi temp1, -16
	st Z, temp1
	std Y+2, temp1 //tmp

	ret
	nop
translatePositions:				// Iterates through Z (positions) to translate into matrix
	cp length, loopcounter
	breq exit2
	nop
	ld temp1, Z+
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
	//subi ZL, -1				// increase pointer (next position is to be read) 
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_0:
	cpi temp1, 0b01000000
	brlo calc32_0
	nop
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_0:
	cpi temp1, 0b00100000
	brlo calc16_0
	nop
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_0:
	cpi temp1, 0b00010000
	brlo calc8_0
	nop
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_0:
	cpi temp1, 0b00001000
	brlo calc4_0
	nop
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_0:
	cpi temp1, 0b00000100
	brlo calc2_0
	nop
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_0:
	cpi temp1, 0b00000010
	brlo calc1_0
	nop
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_0:
	cpi temp1, 0b00000001
	brlo outputrow_0
	nop
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_1:
	cpi temp1, 0b01000000
	brlo calc32_1
	nop
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_1:
	cpi temp1, 0b00100000
	brlo calc16_1
	nop
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_1:
	cpi temp1, 0b00010000
	brlo calc8_1
	nop
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_1:
	cpi temp1, 0b00001000
	brlo calc4_1
	nop
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_1:
	cpi temp1, 0b00000100
	brlo calc2_1
	nop
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_1:
	cpi temp1, 0b00000010
	brlo calc1_1
	nop
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_1:
	cpi temp1, 0b00000001
	brlo outputrow_1
	nop
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_2:
	cpi temp1, 0b01000000
	brlo calc32_2
	nop
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_2:
	cpi temp1, 0b00100000
	brlo calc16_2
	nop
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_2:
	cpi temp1, 0b00010000
	brlo calc8_2
	nop
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_2:
	cpi temp1, 0b00001000
	brlo calc4_2
	nop
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_2:
	cpi temp1, 0b00000100
	brlo calc2_2
	nop
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_2:
	cpi temp1, 0b00000010
	brlo calc1_2
	nop
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_2:
	cpi temp1, 0b00000001
	brlo outputrow_2
	nop
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_3:
	cpi temp1, 0b01000000
	brlo calc32_3
	nop
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_3:
	cpi temp1, 0b00100000
	brlo calc16_3
	nop
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_3:
	cpi temp1, 0b00010000
	brlo calc8_3
	nop
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_3:
	cpi temp1, 0b00001000
	brlo calc4_3
	nop
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_3:
	cpi temp1, 0b00000100
	brlo calc2_3
	nop
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_3:
	cpi temp1, 0b00000010
	brlo calc1_3
	nop
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_3:
	cpi temp1, 0b00000001
	brlo outputrow_3
	nop
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_4:
	cpi temp1, 0b01000000
	brlo calc32_4
	nop
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_4:
	cpi temp1, 0b00100000
	brlo calc16_4
	nop
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_4:
	cpi temp1, 0b00010000
	brlo calc8_4
	nop
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_4:
	cpi temp1, 0b00001000
	brlo calc4_4
	nop
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_4:
	cpi temp1, 0b00000100
	brlo calc2_4
	nop
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_4:
	cpi temp1, 0b00000010
	brlo calc1_4
	nop
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_4:
	cpi temp1, 0b00000001
	brlo outputrow_4
	nop
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_5:
	cpi temp1, 0b01000000
	brlo calc32_5
	nop
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_5:
	cpi temp1, 0b00100000
	brlo calc16_5
	nop
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_5:
	cpi temp1, 0b00010000
	brlo calc8_5
	nop
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_5:
	cpi temp1, 0b00001000
	brlo calc4_5
	nop
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_5:
	cpi temp1, 0b00000100
	brlo calc2_5
	nop
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_5:
	cpi temp1, 0b00000010
	brlo calc1_5
	nop
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_5:
	cpi temp1, 0b00000001
	brlo outputrow_5
	nop
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_6:
	cpi temp1, 0b01000000
	brlo calc32_6
	nop
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_6:
	cpi temp1, 0b00100000
	brlo calc16_6
	nop
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_6:
	cpi temp1, 0b00010000
	brlo calc8_6
	nop
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_6:
	cpi temp1, 0b00001000
	brlo calc4_6
	nop
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_6:
	cpi temp1, 0b00000100
	brlo calc2_6
	nop
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_6:
	cpi temp1, 0b00000010
	brlo calc1_6
	nop
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_6:
	cpi temp1, 0b00000001
	brlo outputrow_6
	nop
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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
	ldi r26, 0b01000000
	neg r26
	sub end, r26
	subi temp1, 0b10000000
calc64_7:
	cpi temp1, 0b01000000
	brlo calc32_7
	nop
	ldi r26, 0b10000000
	neg r26
	sub end, r26
	subi temp1, 0b01000000
calc32_7:
	cpi temp1, 0b00100000
	brlo calc16_7
	nop
	ldi r26, 0b00000001
	neg r26
	sub end, r26
	subi temp1, 0b00100000
calc16_7:
	cpi temp1, 0b00010000
	brlo calc8_7
	nop
	ldi r26, 0b00000010
	neg r26
	sub end, r26
	subi temp1, 0b00010000
calc8_7:
	cpi temp1, 0b00001000
	brlo calc4_7
	nop
	ldi r26, 0b00000100
	neg r26
	sub end, r26
	subi temp1, 0b00001000
calc4_7:
	cpi temp1, 0b00000100
	brlo calc2_7
	nop
	ldi r26, 0b00001000
	neg r26
	sub end, r26
	subi temp1, 0b00000100
calc2_7:
	cpi temp1, 0b00000010
	brlo calc1_7
	nop
	ldi r26, 0b00010000
	neg r26
	sub end, r26
	subi temp1, 0b00000010
calc1_7:
	cpi temp1, 0b00000001
	brlo outputrow_7
	nop
	ldi r26, 0b00100000
	neg r26
	sub end, r26
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

	jmp joyinputY //test
	nop

	;Compare input and branch accordingly

/*	
	cpi temp3, 100
	brsh west
	nop
	cpi temp3, 5
	brlo east
	nop
	note to self: compares innan Y-axeln
	*/
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
	lds temp4, ADCH //ändrade till temp4 från temp3

	jmp compareinput //tmp
	nop
// yntt
compareinput:	
	cpi temp3, 100
	brsh west
	nop
	cpi temp3, 5
	brlo east
	nop	
	cpi temp4, 90
	brsh north
	nop
	cpi temp4, 1
	brlo south 
	nop
	jmp exitinput			;Exit if no input 
	nop
north:
	ldi direction, 0b00001000
	jmp calcDirection
	nop
south:
	ldi direction, 0b00000100
	jmp calcDirection
	nop
west:
	ldi direction, 0b00000010
	jmp calcDirection 
	nop
east:
	ldi direction, 0b00000001
	jmp calcDirection
	nop
calcDirection:				;Checks value of "direction" and moves snake's head accordingly
	std Y+7, direction ;tmp
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
moveWest:					;Move sideways = read old position of head,
	ld temp1, Z				;subtract/add LSB of X position (bit value 16), 
	subi temp1, -16			;then insert new value back to Z
	st Z, temp1
	jmp exitinput
	nop
moveEast:					
	ld temp1, Z
	subi temp1, 16
	st Z, temp1
	jmp exitinput
	nop
moveNorth:					;Move upwards/downwards = read old position,
	ld temp1, Z				;subtract/add LSB of Y position (bit value 1),
	subi temp1, 1			;then insert new value back to Z
	st Z, temp1
	jmp exitinput
	nop
moveSouth:
	ld temp1, Z
	subi temp1, -1
	st Z, temp1
	jmp exitinput
	nop
exitinput:					;Go back to main after moving
	ret

resetMatrix:				;Troubleshooting, reset matrix
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

gameUpdateTimer:
	ldi updateGame, 0b00000001
	reti
	nop
/* *********** Gamla ADMUX värden **************
	//////// VERSION 1.0 ////////////

	X-axeln
	lds temp2, ADMUX
	ldi temp3, 0b00000101
	or temp2, temp3
	sts ADMUX, temp2
	
	Y-axeln
	lds temp2, ADMUX
	ldi temp3, 0b11111110
	and temp2, temp3
	or temp2, temp3
	sts ADMUX, temp2

	////////// VERSION 2.0 ///////////////
	
	X-axeln
	;ADMUX
	lds temp2, ADMUX
	andi temp2, 0b11111000
	ldi temp3, 0b00000101
	or temp2, temp3
	sts ADMUX, temp2
	;ADSCRA
	lds temp2, ADCSRA
	ori	temp2, 0b01000000
	sts ADCSRA, temp2

	Y-axeln
	//ADMUX
	lds temp2, ADMUX
	ldi temp3, 0b00000100
	andi temp2, 0b11111000
	or temp2, temp3
	sts ADMUX, temp2
	//ADSCRA
	lds temp2, ADCSRA
	ori	temp2, 0b01000000
	sts ADCSRA, temp2
	
	/////// VERSION 3.0 (nuvarande) /////////
	För att återställa:
	Ändra init tillbaka till det utkommenterade högst upp, 
	ersätt X & Y input till version 2 (wait1 & 2 är oförändrade)

*/